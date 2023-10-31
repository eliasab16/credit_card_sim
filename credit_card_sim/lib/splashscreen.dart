import 'package:credit_card_sim/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// On this page, we choose which account we wish to show information for (think of this as a substitute for a login page)
/// When the user picks an account number, they can then move on to the credit card statement page/dashboard

class SplashScreen extends StatefulWidget {
  static Route get route => MaterialPageRoute(
      builder: (context) => const SplashScreen(),
    );
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<String> accountIds = [];
  String? selectedAccountId;

  Future<void> fetchAccountIds() async {
    // we want to display the available accounts to the user to choose from
    CollectionReference accountsCollection = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountsSnapshot = await accountsCollection.get();

    for (var accountDocument in accountsSnapshot.docs) {
      accountIds.add(accountDocument.id);
    }

    setState(() {});
  }

  Future<void> fetchAccount(BuildContext context, String accountId) async {
    DocumentReference accountDocument = FirebaseFirestore.instance.collection('accounts').doc(accountId);
    DocumentSnapshot accountSnapshot = await accountDocument.get();
    accountDocument.get().then((value) => {
      Navigator
      .of(context)
      .push(DashboardScreen.routeWithName(
        clientName: accountSnapshot.get('name'),
        accountId: accountId
        ),
      )
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome back!'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Please choose an account:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 200,
              width: 300,
              child: Card(
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: selectedAccountId,
                        items: accountIds.map((accountId) => DropdownMenuItem<String>(value: accountId, child: Text(accountId))).toList(),
                        onChanged: (accountId) {
                          setState(() {
                            selectedAccountId = accountId;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedAccountId != null) {
                            fetchAccount(context, selectedAccountId!);
                          }
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    fetchAccountIds();
  }
}
