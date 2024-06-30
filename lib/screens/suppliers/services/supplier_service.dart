import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class SupplierService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSupplier(Map<String, dynamic> supplierData) async {
    try {
      await _firestore
          .collection(CollectionNames.suppliers)
          .add(supplierData);
    } catch (e) {
      throw Exception('Failed to add supplier: $e');
    }
  }

  static Future<void> updateSupplier(String supplierId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionNames.suppliers)
          .doc(supplierId)
          .update(newData);
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  static Future<void> deleteSupplier(String supplierId) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionNames.suppliers)
          .doc(supplierId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }

}
