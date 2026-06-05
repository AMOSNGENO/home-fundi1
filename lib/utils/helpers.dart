import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

String money(dynamic value) {
  final number = double.tryParse('${value ?? 0}') ?? 0;
  return NumberFormat.currency(symbol: 'KES ', decimalDigits: 0).format(number);
}

String readableStatus(String status) =>
    status.replaceAll('_', ' ').toUpperCase();

Color statusColor(String status) => AppColors.statusColor(status);

void showToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          error ? AppColors.primaryRed : const Color(0xFF059669),
    ),
  );
}
