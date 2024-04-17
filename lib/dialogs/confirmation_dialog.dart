import 'package:flutter/material.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title, message;
  final VoidCallback onConfirm;
  const ConfirmationDialog({super.key, required this.title, required this.message, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onConfirm,
            child: const Text(Strings.delete),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(Strings.cancel),
          ),
        ],
      ),
    );
  }
}
