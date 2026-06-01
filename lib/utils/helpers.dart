import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String money(dynamic value) {
  final number = double.tryParse('${value ?? 0}') ?? 0;
  return NumberFormat.currency(symbol: 'KES ', decimalDigits: 0).format(number);
}

String readableStatus(String status) =>
    status.replaceAll('_', ' ').toUpperCase();

Color statusColor(String status) {
  switch (status) {
    case 'completed':
      return Colors.green;
    case 'accepted':
    case 'in_progress':
      return Colors.blue;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.orange;
  }
}

void showToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
    ),
  );
}
