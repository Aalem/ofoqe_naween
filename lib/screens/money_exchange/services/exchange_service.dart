import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/exchange_model.dart';

class ExchangeService {
  final CollectionReference _exchangeCollection =
  FirebaseFirestore.instance.collection('exchanges');

  // Add a new exchange
  Future<void> addExchange(ExchangeModel exchange) async {
    try {
      await _exchangeCollection.add(exchange.toMap());
    } catch (e) {
      print('Error adding exchange: $e');
      rethrow;
    }
  }

  // Update an existing exchange
  Future<void> updateExchange(String id, Map<String, dynamic> data) async {
    try {
      await _exchangeCollection.doc(id).update(data);
    } catch (e) {
      print('Error updating exchange: $e');
      rethrow;
    }
  }

  // Delete an exchange
  Future<void> deleteExchange(String id) async {
    try {
      await _exchangeCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting exchange: $e');
      rethrow;
    }
  }

  // Fetch all exchanges
  Future<List<ExchangeModel>> getExchanges() async {
    try {
      final QuerySnapshot snapshot = await _exchangeCollection.get();
      return snapshot.docs
          .map((doc) => ExchangeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching exchanges: $e');
      rethrow;
    }
  }

  // Fetch a specific exchange by ID
  Future<ExchangeModel?> getExchangeById(String id) async {
    try {
      final DocumentSnapshot doc = await _exchangeCollection.doc(id).get();
      if (doc.exists) {
        return ExchangeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching exchange: $e');
      rethrow;
    }
  }
}
