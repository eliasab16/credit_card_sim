import * as admin from 'firebase-admin';
import * as CODE from './codes';

import { Timestamp } from 'firebase-admin/firestore'
import { DocumentReference } from '@google-cloud/firestore';


const {onRequest} = require("firebase-functions/v2/https");

const firestore = admin.firestore();

export const submitNewTransaction = onRequest(async (req: any, res: any) => {
    const txnData: { [key: string]: any } = {};

    try {
        const reqData = req.body.data;

        if (!reqData) {
            // Handle the case where reqData or txnId is not defined
            res.json({'result': 'invalid'});
        }

        const txnId = txnData['txnId'] = reqData.txnId;
        const txnType = txnData['txnType'] = reqData.txnType;
        const txnAmount = txnData['txnAmount'] = reqData.txnAmount ? Number(reqData.txnAmount) : null
        const accountId = txnData['accountId'] = reqData.accountId;

        return validateTransaction(txnData).then(async (result) => {
            if (result != 'success') {
                res.json({'result': result});
            } else {
                const accountDocRef = firestore.collection('accounts').doc(accountId);
                const pendingCollectionRef = accountDocRef.collection('pending_transactions');

                const accountDocSnapshot = await accountDocRef.get();
                const availableCredit = accountDocSnapshot.data()!.available_credit;
                const payableBalance = accountDocSnapshot.data()!.payable_balance;

                // determine if pending or settled and add the new transaction
                if (txnType == CODE.TXN_AUTHED || txnType == CODE.PAYMENT_INITIATED) {
                    // has to be transactional because we're updating multiple locations (adding doc and updating balances)
                    firestore.runTransaction(async (t) => {
                        t.set(pendingCollectionRef.doc(txnId), {
                            'type': txnType,
                            'amount': txnAmount,
                            'open': true,
                            'time': Timestamp.now()
                        });

                        if (txnType == CODE.TXN_AUTHED) {
                            t.update(accountDocRef, { 'available_credit': availableCredit - txnAmount! });
                        } else {
                            t.update(accountDocRef, { 'payable_balance': payableBalance - txnAmount! });
                        }
                    });
                } else {
                    // has to be transactional because we're updating multiple locations
                    firestore.runTransaction(async (t) => {
                        // flag the pending transaction as closed
                        const pendingDocRef = pendingCollectionRef.doc(txnId)
                        const pendingSnapshot = await pendingDocRef.get();
                        const pendingTxn = pendingSnapshot.data()!;

                        let payableBalanceChange = 0;
                        let availableCreditChange = 0;

                        t.update(pendingDocRef, {'open': false});

                        // add the settled transaction
                        const settledCollectionRef = accountDocRef.collection('settled_transactions');
                        t.set(settledCollectionRef.doc(txnId), {
                            'type': txnType,
                            'amount': txnAmount,
                            'time': Timestamp.now()
                        });

                        // update the balances accordingly
                        switch(txnType) {
                            case CODE.TXN_AUTH_CLEARED:
                                availableCreditChange = pendingTxn.amount;
                            case CODE.TXN_SETTLED:
                                // extra calculations because settled amount might change
                                availableCreditChange = pendingTxn.amount - txnAmount!;
                                payableBalanceChange = txnAmount!;
                            case CODE.PAYMENT_CANCELED:
                                payableBalanceChange = -1 * txnAmount!;
                            case CODE.PAYMENT_POSTED:
                                availableCreditChange = pendingTxn.amount
                        }

                        t.update(accountDocRef, {
                            'available_credit': availableCredit + availableCreditChange,
                            'payable_balance': payableBalance + payableBalanceChange,
                        })
                    })
                }
                // success
                res.json({'result': result});
            }
        })
    } catch (e) {
        console.error(e);
        res.json(e);
    }
});

// before we submit a transaction we need to validate things like: amount, possible fraud, corresponding transaction, etc.
// output: return error code
async function validateTransaction(txnData: { [key: string]: any }): Promise<String | null> {
    const txnId = txnData['txnId'];
    const txnType = txnData['txnType'];
    const accountId = txnData['accountId'];

    const accountRef = firestore.collection('accounts').doc(accountId);

    // check if we have a duplicate pending id
    const existingTransaction = await getTransactionById(txnId, accountRef)
    if (existingTransaction != null && !existingTransaction.open) {
        return CODE.DUPLICATE_ID;
    }

    if (
        txnType == CODE.TXN_SETTLED ||
        txnType == CODE.TXN_AUTH_CLEARED ||
        txnType == CODE.PAYMENT_POSTED ||
        txnType == CODE.PAYMENT_CANCELED
        ) {
            const valid = await validateCorrespondingTxn(txnId, accountRef);
            if (!valid) {
                return CODE.NO_CORRESPONDING_TXN;
            }
    }

    if (txnType == CODE.TXN_AUTHED || txnType == CODE.TXN_SETTLED) {
        const valid = await validateSufficientCredit(txnData, accountRef);

        if (!valid) {
            return CODE.INSUFFICIENT_CREDIT;
        }
    }
    
    // should freeze credit card
    // if (txnType == CODE.TXN_AUTHED) {
    //     const fraud = await checkForFraud(txnAmount, accountRef);

    //     if (fraud) {
    //         return CODE.SUSPICIOUS_ACITIVTY;
    //     }
    // }

    return CODE.SUCCESS;
}


async function validateSufficientCredit(txnData: any, accountRef: DocumentReference): Promise<boolean> {
    const accountSnapshot = await accountRef.get();
    const txnId = txnData['txnId'];
    const txnType = txnData['txnType'];
    var txnAmount = Number(txnData['txnAmount']);

    if (accountSnapshot.exists) {
        // we need to get the pending transaction amount so we only check the difference for sufficient credit
        if (txnType == CODE.TXN_SETTLED) {
            const pendingTxn = await getTransactionById(txnId, accountRef);
            if (pendingTxn != null) {
                const pendingAmount: number = pendingTxn.amount;
                if (txnAmount <= pendingAmount) {
                    return true;
                }
                txnAmount = pendingAmount - txnAmount;
            }
        }

        const available_credit = accountSnapshot.data()!.available_credit;
        return (available_credit >= txnAmount);
    } else {
        // todo: what happens if not?
        return false;
    }
}

// todo: pass-through function, consider deleting or refactoring
async function validateCorrespondingTxn(txnId: string, accountRef: DocumentReference): Promise<boolean> {
    const result = await getTransactionById(txnId, accountRef);
    
    return (result != null && result.open);
}

// a simplistic function that checks if there were other transactions with the same amount within the last X minutes
// async function checkForFraud(txnAmount: number, accountRef: DocumentReference): Promise<boolean> {
    
// }

// todo: this is sometimes called multiple times -> consider storing the transaction and reuse it
async function getTransactionById(txnId: string, accountRef: DocumentReference): Promise<any> {
    try {
        const txnRef = accountRef.collection('pending_transactions').doc(txnId);
        const documentSnapshot = await txnRef.get();
    
        if (documentSnapshot.exists) {
            const documentData = documentSnapshot.data();
            return documentData;
          } else {
            return null;
          }
    } catch (error) {
        throw error;
    }
}