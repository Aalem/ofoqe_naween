import 'package:flutter/material.dart';
import 'package:ofoqe_naween/main.dart';

class NotificationService {
  // Private constructor
  NotificationService._();

  // Singleton instance
  static final NotificationService _instance = NotificationService._();

  // Getter for the singleton instance
  factory NotificationService() => _instance;

  void showSuccess(String message) {
    final snackBar = SnackBar(
      content: Text(message, textDirection: TextDirection.rtl),
      backgroundColor: Colors.green,
    );
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showError(String message) {
    final snackBar = SnackBar(
      content: Text(message, textDirection: TextDirection.rtl),
      backgroundColor: Colors.red,
    );
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
