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
  dynamic _txnRequestResponse;

  List<String> pendingTransactions = ['1', '2', '3', '4','5'];
  List<String> settledTransactions = [];

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

  Future<String> submitTransaction() async {
    dynamic txnRequestResponse;
    developer.log('inside submit transaction');
    try {
      txnRequestResponse = await FirebaseFunctions.instance.httpsCallable('submitNewTransaction').call(
        {
          'txnId': _idController.text,
          'txnType': _transactionTypeController.text,
          'txnAmount': _amountController.text,
          'accountId': widget.accountId
        }
      );
      developer.log('submit a new transaction');

      setState(() {
        _txnRequestResponse = txnRequestResponse.data ?? 'success';
      });
  } on FirebaseFunctionsException catch (error) {
      // TODO: handle errors appropriately
  }

    return '';
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
          height: 400,
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
                      items: const [
                        DropdownMenuItem(
                          value: 'txn_authed',
                          child: Text('TXN_AUTHED'),
                        ),
                        DropdownMenuItem(
                          value: 'txn_settled',
                          child: Text('TXN_SETTLED'),
                        ),
                        DropdownMenuItem(
                          value: 'txn_auth_cleared',
                          child: Text('TXN_AUTH_CLEARED'),
                        ),
                        DropdownMenuItem(
                          value: 'payment_initiated',
                          child: Text('PAYMENT_INITIATED'),
                        ),
                        DropdownMenuItem(
                          value: 'payment_posted',
                          child: Text('PAYMENT_POSTED'),
                        ),
                        DropdownMenuItem(
                          value: 'payment_canceled',
                          child: Text('PAYMENT_CANCELED'),
                        ),
                      ],
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
                    (_txnRequestResponse != null) ?
                      (_txnRequestResponse == 'success') ?
                        const Text(
                          'Transaction went through successfully!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 117, 200, 39)
                          )) :
                        Text(
                          'Declined: ${_txnRequestResponse.toString()}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 237, 106, 97)
                          )) :
                        const Text(''),
                    const Spacer(),
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

  Widget showTransactions() {
    return Column(
    children: [
      const SizedBox(height: 16),
      const Text(
        'Pending Transactions:',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Card(
        child: SizedBox(
          height: 120,
          width: 400,
          child: ListView(
            children: pendingTransactions.map((transaction) => Text(transaction)).toList(),
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Settled Transactions:',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Card(
        child: SizedBox(
          height: 120,
          width: 400,
          child: ListView(
            children: settledTransactions.map((transaction) => Text(transaction)).toList(),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
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
              showTransactions(),
              buildForm(),
            ],
          )
        ),
      )
    );
  }
}
