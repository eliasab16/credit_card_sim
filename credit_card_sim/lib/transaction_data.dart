import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDataProvider {
  final DocumentReference<Map<String, dynamic>> _collection;

  TransactionDataProvider(String accountId)
      : _collection = FirebaseFirestore.instance.collection('accounts').doc(accountId);

  Stream<List<CustomDocument>> get sortedPendingStream {
    // we only want the pending transactions that haven't been settled yet
    return _collection.collection('pending_transactions').where('open', isEqualTo: true).snapshots().map((snapshot) {
      final documents = snapshot.docs
          .map((doc) => CustomDocument(doc.id, doc.data()))
          .toList();

      documents.sort((a, b) => b.data['time'].compareTo(a.data['time']));

      return documents;
    });
  }

  Stream<List<CustomDocument>> get sortedSettledStream {
    return _collection.collection('settled_transactions').where('type', whereIn: ['txn_settled', 'payment_posted']).snapshots().map((snapshot) {
      final documents = snapshot.docs
          .map((doc) => CustomDocument(doc.id, doc.data()))
          .toList();

      documents.sort((a, b) => b.data['time'].compareTo(a.data['time']));

      return documents;
    });
  }

}

class CustomDocument {
  final String id;
  final Map<String, dynamic> data;

  CustomDocument(this.id, this.data);
}