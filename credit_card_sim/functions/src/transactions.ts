import { async } from '@firebase/util';
import * as admin from 'firebase-admin';

const {onRequest} = require("firebase-functions/v2/https");

const firestore = admin.firestore();

export const submitNewTransaction = onRequest(async (req: any, res: any) => {
    try {
        const txnData = req.body.data;

        const txnId = txnData.id;
        const txnType = txnData.type;
        const txnAmount = txnData.amount ? txnData.amount : null;
    }
})