import 'package:flutter/material.dart';

class NotificationService {
  // Private constructor
  NotificationService._();

  // Singleton instance
  static final NotificationService _instance = NotificationService._();

  // Getter for the singleton instance
  factory NotificationService() => _instance;

  void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message, textDirection: TextDirection.rtl),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message, textDirection: TextDirection.rtl),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
