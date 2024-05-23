import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';

class MoneyExchangeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _moneyExchangeCollection = 'money_exchange';

  static Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final double debit = transaction.debit;
      final double credit = transaction.credit;
      final double balanceChange = credit - debit;

      await _firestore.runTransaction((txn) async {
        DocumentReference balanceRef = _firestore.collection('balance').doc('currentBalance');

        DocumentSnapshot balanceSnapshot = await txn.get(balanceRef);

        if (!balanceSnapshot.exists) {
          txn.set(balanceRef, {'balance': balanceChange});
        } else {
          txn.update(balanceRef, {
            'balance': FieldValue.increment(balanceChange),
          });
        }

        DocumentReference transactionRef = _firestore.collection(_moneyExchangeCollection).doc();
        txn.set(transactionRef, transaction.toMap());
      });
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  static Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.runTransaction((txn) async {
        DocumentReference transactionRef = _firestore.collection(_moneyExchangeCollection).doc(transactionId);

        DocumentSnapshot transactionSnapshot = await txn.get(transactionRef);

        if (!transactionSnapshot.exists) {
          throw Exception('Transaction not found');
        }

        final transactionData = transactionSnapshot.data() as Map<String, dynamic>;
        final TransactionModel transaction = TransactionModel.fromMap(transactionData, transactionId);
        final double balanceChange = transaction.debit - transaction.credit;

        DocumentReference balanceRef = _firestore.collection('balance').doc('currentBalance');

        txn.update(balanceRef, {
          'balance': FieldValue.increment(balanceChange),
        });

        txn.delete(transactionRef);
      });
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  static Future<double> getCurrentBalance() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> balanceSnapshot = await _firestore
          .collection('balance')
          .doc('currentBalance')
          .get();
      if (balanceSnapshot.exists) {
        return balanceSnapshot.data()?['balance']?.toDouble() ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to fetch current balance: $e');
    }
  }

  static Future<void> updateBalance(double newBalance) async {
    try {
      DocumentReference balanceRef = _firestore.collection('balance').doc('currentBalance');
      await balanceRef.set({'balance': newBalance}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update balance: $e');
    }
  }



  static Future<void> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    try {
      await _firestore.collection(_moneyExchangeCollection).doc(id).update(transactionData);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
}
