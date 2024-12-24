import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/money_exchange/collection_fields/balance.dart';
import 'package:ofoqe_naween/pages/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class MoneyExchangeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final double debit = transaction.debit;
      final double credit = transaction.credit;
      final double balanceChange = credit - debit;

      await _firestore.runTransaction((txn) async {
        DocumentReference balanceRef = _firestore.collection(CollectionNames.balances).doc(BalanceFields.documentId);

        DocumentSnapshot balanceSnapshot = await txn.get(balanceRef);

        if (!balanceSnapshot.exists) {
          txn.set(balanceRef, {BalanceFields.balance: balanceChange});
        } else {
          txn.update(balanceRef, {
            BalanceFields.balance: FieldValue.increment(balanceChange),
          });
        }

        DocumentReference transactionRef = _firestore.collection(CollectionNames.transactions).doc();
        txn.set(transactionRef, transaction.toMap());
      });
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  static Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.runTransaction((txn) async {
        DocumentReference transactionRef = _firestore.collection(CollectionNames.transactions).doc(transactionId);

        DocumentSnapshot transactionSnapshot = await txn.get(transactionRef);

        if (!transactionSnapshot.exists) {
          throw Exception('Transaction not found');
        }

        final transactionData = transactionSnapshot.data() as Map<String, dynamic>;
        final TransactionModel transaction = TransactionModel.fromMap(transactionData, transactionId);
        double balanceChange = 0;

        if (transaction.debit != null && transaction.debit > 0) {
          balanceChange = -transaction.debit; // Subtract debit amount from balance
        } else if (transaction.credit != null && transaction.credit > 0) {
          balanceChange = transaction.credit; // Add credit amount to balance
        }

        DocumentReference balanceRef = _firestore.collection(CollectionNames.balances).doc(BalanceFields.documentId);

        txn.update(balanceRef, {
          BalanceFields.balance: FieldValue.increment(balanceChange),
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
          .collection(CollectionNames.balances)
          .doc(BalanceFields.documentId)
          .get();
      if (balanceSnapshot.exists) {
        return balanceSnapshot.data()?[BalanceFields.balance]?.toDouble() ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to fetch current balance: $e');
    }
  }

  static Future<void> updateBalance(double newBalance) async {
    try {
      DocumentReference balanceRef = _firestore.collection(CollectionNames.balances).doc(BalanceFields.documentId);
      await balanceRef.set({BalanceFields.balance: newBalance}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update balance: $e');
    }
  }

  static Stream<double> getBalanceStream() {
    return _firestore.collection(CollectionNames.balances).doc(BalanceFields.documentId).snapshots().map((snapshot) {

      if (snapshot.exists) {
        var balance = snapshot.data()?[BalanceFields.balance];
        if (balance is int) {
          return balance.toDouble();
        } else if (balance is double) {
          return balance;
        } else {
          return 0.0; // Default value if the type is unexpected
        }
      }
      return 0.0;
    });
  }

  static Future<void> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    try {
      await _firestore.collection(CollectionNames.transactions).doc(id).update(transactionData);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
}
