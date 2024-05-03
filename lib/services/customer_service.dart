import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class CustomerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _customersCollection = 'customers';

  static Future<void> addCustomer(Map<String, dynamic> customerData) async {
    try {
      await _firestore
          .collection(_customersCollection)
          .add(customerData);
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  static Future<void> updateCustomer(String customerId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection(_customersCollection)
          .doc(customerId)
          .update(newData);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  static Future<void> deleteCustomer(String customerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

// Other methods for validation, data transformation, error handling, etc.
}
