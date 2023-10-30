import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static Route routeWithName({required String clientName}) {
    return MaterialPageRoute(
      builder: (context) => DashboardScreen(clientName: clientName),
    );
  }

  const DashboardScreen({
    super.key,
    required this.clientName  
  });

  final String clientName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _amountController = TextEditingController();
  var _disableAmount = false;

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

  Widget buildForm() {
    return Column(
      children: [
        const Text(
          'Submit a transaction',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(
          height: 400,
          width: 400,
          child: Card(
            margin: const EdgeInsets.all(16),
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
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save the data.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.clientName}'),
      ),
      body: Center(child: buildForm()),
    );
  }
}
