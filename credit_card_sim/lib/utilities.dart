import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


String formatTime(Timestamp timestamp) {
  DateFormat dateFormat = DateFormat('MM/dd, HH:mm');
  DateTime dateTime = timestamp.toDate();

  return dateFormat.format(dateTime);
}

String formatTransactionDisplay(String txnId, Map<String, dynamic> txnData) {
    final type = txnData['type'];
    final time = formatTime(txnData['time']);
    final timeFinalized = (txnData['time_finalized'] != null) ? formatTime(txnData['time_finalized']) : null;
    var amount = '\$${txnData['amount']}';
    
    if (type == 'payment_posted' || type == 'payment_initiated') {
      amount = '-$amount';
    }
    
    var displayText = '($time):   $amount          [$txnId]';
    
    if (timeFinalized != null) {
      displayText += ' (finalized @ $timeFinalized)';
    }

    return displayText;
}