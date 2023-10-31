import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_sim/constants.dart';
import 'package:credit_card_sim/transaction_data.dart';
import 'package:credit_card_sim/utilities.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as developer;


class DashboardScreen extends StatefulWidget {
  static Route routeWithName({
    required String clientName,
    required String accountId,
    }) {
    return MaterialPageRoute(
      builder: (context) => DashboardScreen(
        clientName: clientName,
        accountId: accountId
        ),
    );
  }

  const DashboardScreen({
    super.key,
    required this.clientName,
    required this.accountId,
  });

  final String clientName;
  final String accountId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _amountController = TextEditingController();
  
  var _disableAmount = false;

  int _availableCredit = 0;
  int _payableBalance = 0;
  List<CustomDocument> _pendingTransactions = [];
  List<CustomDocument> _settledTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchInitialAccountData();
    setupUpdatesStream();

    final transactionDataProvider = TransactionDataProvider(widget.accountId);

    transactionDataProvider.sortedPendingStream.listen((documents) {
      setState(() {
        _pendingTransactions = documents;
      });
    });
    
    transactionDataProvider.sortedSettledStream.listen((documents) {
      setState(() {
        _settledTransactions = documents;
      });
    });
  }

  void onDropdownChanged(String? value) {
    setState(() {
      _transactionTypeController.text = value!;
      if (['payment_posted', 'payment_canceled', 'txn_auth_cleared'].any((type) => type == _transactionTypeController.text)) {
        _disableAmount = true;
      } else {
        _disableAmount = false;
      }
    });
  }

  Future<void> fetchInitialAccountData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .doc(widget.accountId)
        .get();

    final accountData = snapshot.data() as Map<String, dynamic>;

    final availableCredit = accountData['available_credit'];
    final payableBalance = accountData['payable_balance'];

    setState(() {
      _availableCredit = availableCredit;
      _payableBalance  = payableBalance;
    });
  }

  // listens on any changes on the account (new transactions, balance change, etc.)
  void setupUpdatesStream() {
    final doc = FirebaseFirestore.instance.collection('accounts').doc(widget.accountId);

    doc.snapshots().listen((snapshot) {
      final accountData = snapshot.data() as Map<String, dynamic>;

      final availableCredit = accountData['available_credit'];
      final payableBalance = accountData['payable_balance'];

      setState(() {
        _availableCredit = availableCredit;
        _payableBalance  = payableBalance;
      });
    });
  }

  Future<void> submitTransaction() async {
    dynamic txnRequestResponse;
    try {
      txnRequestResponse = await FirebaseFunctions.instance.httpsCallable('submitNewTransaction').call(
        {
          'txnId': _idController.text,
          'txnType': _transactionTypeController.text,
          'txnAmount': _amountController.text,
          'accountId': widget.accountId
        }
      );
      // display the response: succes or declined with description
      showPopup(txnRequestResponse.data.toString());
    } on FirebaseFunctionsException catch (error) {
        rethrow;
    }
  }

  void showPopup(String message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: 350,
          height: 150,
          decoration: BoxDecoration(
            color: message == 'success' ? 
                const Color.fromARGB(255, 117, 200, 39) :
                const Color.fromARGB(255, 237, 106, 97),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message == 'success' ?
                    'Transaction went through successfully!' :
                    'Declined: $message',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Colors.black,
                      ),
                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildForm() {
    return Column(
      children: [
        const Text(
          'Submit a transaction:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),
        ),

        SizedBox(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'ID:',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID is required.';
                        }
                        return null;
                      },
                    ),

                    DropdownButtonFormField(
                      onChanged: onDropdownChanged,
                      items: dropdownOptions,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Type:',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Transaction type is required.';
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      enabled: !_disableAmount,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _disableAmount ? 'Amount field disabled' : 'Amount:',
                      ),
                      validator: (value) {
                        if (!_disableAmount) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required.';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Amount must be an integer.';
                          }
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Time: recorded automatically with submit', 
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          submitTransaction();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget transactionsDashboard() {
    return Column(
    children: [
      SizedBox(
        width: 400,
        child: Row(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Available Credit: \$$_availableCredit'),
              ),
            ),

            const Spacer(),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Payable Balance: \$$_payableBalance'),
              ),
            )
          ],
        ),
      ),

      const SizedBox(height: 16),

      const Text(
        'Pending Transactions:',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      buildTransactionsList(context, _pendingTransactions),

      const SizedBox(height: 16),

      const Text(
        'Settled Transactions:',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      buildTransactionsList(context, _settledTransactions),

      const SizedBox(height: 16),
      ],
    );
  }

  Widget buildTransactionsList(BuildContext context, List<CustomDocument> transactionsList) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 200,
          width: 500,
          child: ListView.builder(
            itemCount: transactionsList.length,
            itemBuilder: (context, index) {
              final txnData = transactionsList[index].data;
              final txnId = transactionsList[index].id;
      
              return Text(
                formatTransactionDisplay(txnId, txnData)
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.clientName}'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              transactionsDashboard(),
              buildForm(),
            ],
          )
        ),
      )
    );
  }
}
