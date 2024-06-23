import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:ofoqe_naween/screens/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class CustomerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addCustomer(Map<String, dynamic> customerData) async {
    try {
      customerData[CustomerFields.date] = DateTime.now().toString();
      await _firestore
          .collection(CollectionNames.customers)
          .add(customerData);
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  static Future<void> updateCustomer(String customerId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionNames.customers)
          .doc(customerId)
          .update(newData);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  static Future<void> deleteCustomer(String customerId) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionNames.customers)
          .doc(customerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

// Other methods for validation, data transformation, error handling, etc.
}
