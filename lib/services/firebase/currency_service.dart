import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/models/currency.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class CurrencyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all currencies from the 'currencies' collection.
  static Future<List<Currency>> getCurrencies() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection(CollectionNames.currencies).get();

      return snapshot.docs
          .map((doc) => Currency.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch currencies: $e');
    }
  }

  /// Adds a new currency to the 'currencies' collection.
  static Future<void> addCurrency(Currency currency) async {
    try {
      await _firestore
          .collection(CollectionNames.currencies)
          .add(currency.toMap());
    } catch (e) {
      throw Exception('Failed to add currency: $e');
    }
  }

  /// Deletes a currency by ID.
  static Future<void> deleteCurrency(String id) async {
    try {
      await _firestore.collection(CollectionNames.currencies).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete currency: $e');
    }
  }
}
