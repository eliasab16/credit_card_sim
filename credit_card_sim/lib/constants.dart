import 'package:flutter/material.dart';

const dropdownOptions = [
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
];