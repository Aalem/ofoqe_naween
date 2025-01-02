import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/money_exchange/collection_fields/balance.dart';
import 'package:ofoqe_naween/pages/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/values/constants.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';

class MoneyExchangeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update exchange balance based on a transaction
  static Future<void> updateExchangeBalanceByTransaction(
      TransactionModel transaction) async {
    try {
      DocumentReference exchangeBalanceRef = _firestore
          .collection(CollectionNames.balances)
          .doc(transaction.exchangeId);
      DocumentSnapshot exchangeBalanceSnapshot = await exchangeBalanceRef.get();
      double currentBalance = 0;
      final double balanceChange = transaction.debit - transaction.credit;
      if (exchangeBalanceSnapshot.exists) {
        currentBalance =
            (exchangeBalanceSnapshot[BalanceFields.balance] as num?)
                    ?.toDouble() ??
                0.0;

        currentBalance += balanceChange;

        await exchangeBalanceRef.update({
          BalanceFields.balance: currentBalance,
        });
      } else {
        await exchangeBalanceRef.set({
          BalanceFields.balance: balanceChange,
        });
      }
    } catch (e) {
      throw Exception('Failed to update exchange balance: $e');
    }
  }

  static Future<void> _addTransaction(
      Transaction txn, TransactionModel transaction) async {
    DocumentReference transactionRef =
        _firestore.collection(CollectionNames.transactions).doc();
    txn.set(transactionRef, transaction.toMap());
  }

  // Main function to handle adding a transaction
  static Future<void> addTransaction(
      TransactionModel transaction, MEPaymentType paymentType) async {
    try {
      print('running transaction $transaction');
      await _firestore.runTransaction((txn) async {
        // Add the transaction within the transaction
        _addTransaction(txn, transaction);
      });

      // First, update the exchange balance outside the Firestore transaction
      await updateExchangeBalanceByTransaction(transaction);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Delete a transaction from Firestore
  static Future<void> deleteTransaction(String transactionId) async {
    try {
      // Step 1: Fetch the transaction details
      DocumentReference transactionRef = _firestore
          .collection(CollectionNames.transactions)
          .doc(transactionId);
      DocumentSnapshot transactionSnapshot = await transactionRef.get();

      if (!transactionSnapshot.exists) {
        throw Exception('Transaction not found');
      }

      // Map the snapshot to a TransactionModel object
      final transactionData =
          transactionSnapshot.data() as Map<String, dynamic>;
      final TransactionModel transaction =
          TransactionModel.fromMap(transactionData, transactionId);

      final double balanceChange = (transaction.credit ?? 0) -
          (transaction.debit ?? 0); // Reverse the balance change

      // Step 3: Update the exchange balance separately
      await updateExchangeBalanceOnDelete(
          transaction.exchangeId, balanceChange);

      // Step 4: Delete the transaction (outside of the txn)
      await transactionRef.delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Function to delete an exchange, return true if deleted, false if there are transactions
  static Future<void> deleteExchange(String exchangeId) async {
    try {
      // Step 1: Check if there are any transactions related to this exchange
      QuerySnapshot transactionSnapshot = await _firestore
          .collection(CollectionNames.transactions)
          .where('exchange_id', isEqualTo: exchangeId)
          .get();

      if (transactionSnapshot.docs.isNotEmpty) {
        // There are related transactions, throw an error so UI can handle
        throw Exception(
            'There are transactions related to this exchange. Please delete the transactions before deleting the exchange.');
      }

      // Step 2: Fetch the exchange details
      DocumentReference exchangeRef =
          _firestore.collection(CollectionNames.exchanges).doc(exchangeId);
      DocumentSnapshot exchangeSnapshot = await exchangeRef.get();

      if (!exchangeSnapshot.exists) {
        throw Exception('Exchange not found');
      }

      // Step 3: Delete the exchange if there are no transactions
      await exchangeRef.delete();
    } catch (e) {
      throw Exception('Failed to delete exchange: $e');
    }
  }

  // Update the exchange balance when deleting a transaction
  static Future<void> updateExchangeBalanceOnDelete(
      String exchangeId, double balanceChange) async {
    try {
      DocumentReference exchangeBalanceRef =
          _firestore.collection(CollectionNames.balances).doc(exchangeId);

      DocumentSnapshot exchangeBalanceSnapshot = await exchangeBalanceRef.get();

      if (exchangeBalanceSnapshot.exists) {
        await exchangeBalanceRef.update({
          BalanceFields.balance: FieldValue.increment(balanceChange),
        });
      } else {
        await exchangeBalanceRef.set({
          BalanceFields.balance: balanceChange,
        });
      }
    } catch (e) {
      throw Exception('Failed to update exchange balance: $e');
    }
  }

  static Future<void> updateTransaction(
    String transactionId,
    TransactionModel transaction,
    double newExchangeBalance,
  ) async {
    try {
      // Step 1: Update the transaction in Firestore
      await _firestore
          .collection(CollectionNames.transactions)
          .doc(transactionId)
          .update(transaction.toMap());

      // Step 2: Update the exchange balance
      await updateExchangeBalanceDirect(
          newExchangeBalance, transaction.exchangeId);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Get the current general balance
  static Future<double> getGeneralBalance() async {
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
  } // Get the current general balance

  static Future<double> getExchangeBalance(String exchangeId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> balanceSnapshot = await _firestore
          .collection(CollectionNames.balances)
          .doc(exchangeId)
          .get();
      if (balanceSnapshot.exists) {
        return balanceSnapshot.data()?[BalanceFields.balance]?.toDouble() ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to fetch exchange balance: $e');
    }
  }

  static Future<void> updateExchangeBalanceDirect(
      double newBalance, String exchangeId) async {
    try {
      DocumentReference exchangeBalanceRef =
          _firestore.collection(CollectionNames.balances).doc(exchangeId);
      await exchangeBalanceRef.set({
        BalanceFields.balance: newBalance,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update exchange balance: $e');
    }
  }

  static Stream<double> getBalanceStream() {
    return _firestore
        .collection(CollectionNames.balances)
        .snapshots()
        .map((snapshot) {
      double totalBalance = 0.0;

      for (var document in snapshot.docs) {
        var balance = document.data()[BalanceFields.balance];

        if (balance is int) {
          totalBalance += balance.toDouble();
        } else if (balance is double) {
          totalBalance += balance;
        }
      }

      return totalBalance;
    });
  }
}
