import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyExchangeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _moneyExchangeCollection = 'money_exchange';

  static Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    try {
      await _firestore.collection(_moneyExchangeCollection).add(transactionData);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  static Future<void> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    try {
      await _firestore.collection(_moneyExchangeCollection).doc(id).update(transactionData);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection(_moneyExchangeCollection).get();
      return querySnapshot.docs.map<Map<String, dynamic>>((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  static Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('money_exchange').doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

}
