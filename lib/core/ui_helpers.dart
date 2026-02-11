import 'package:flutter/material.dart';

class UIHelpers {
  static void showMessage(BuildContext context, String text, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
