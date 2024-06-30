import 'package:flutter/cupertino.dart';

class BalanceProvider extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners(); // Notify listeners about state change
  }
}