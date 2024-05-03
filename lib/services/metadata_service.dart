import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class MetadataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _metadataCollection = 'metadata';
  static const String _lastCustomerIdField = 'lastCustomerId';
  static const String _lastCustomerIdDocument = 'customer_meta';

  // Get the last customer ID from the metadata collection
  static Future<String?> getLastCustomerId() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_metadataCollection)
          .doc(_lastCustomerIdDocument)
          .get();
      if (snapshot.exists) {
        String lastCustomerId = snapshot.data()?[_lastCustomerIdField];
        int lastCustomerNumber = int.parse(lastCustomerId.substring(1));
        String newCustomerCode = 'C${(lastCustomerNumber + 1).toString().padLeft(4, '0')}';
        return newCustomerCode;
      } else {
        print('Last customer ID document does not exist.');
        await createMetadataCollectionAndDocument();
        return 'C0001';
      }
    } catch (e) {
      print('Error fetching last customer ID: $e');
    }
    return null;
  }

  // Update the last customer ID in the metadata collection
  static Future<void> updateLastCustomerCode(String lastCustomerCode) async {
    try {
      await _firestore
          .collection(_metadataCollection)
          .doc(_lastCustomerIdDocument)
          .set({_lastCustomerIdField: lastCustomerCode});
    } catch (e) {
      print('Error updating last customer code: $e');
    }
  }

  // Create metadata collection and document if they don't exist
  static Future<void> createMetadataCollectionAndDocument() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_metadataCollection)
          .doc(_lastCustomerIdDocument)
          .get();
      if (!snapshot.exists) {
        await _firestore
            .collection(_metadataCollection)
            .doc(_lastCustomerIdDocument)
            .set({_lastCustomerIdField: 'C0001'});
      }
    } catch (e) {
      print('Error creating metadata collection or document: $e');
    }
  }
}
