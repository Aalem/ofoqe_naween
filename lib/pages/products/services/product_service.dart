import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/products/models/product.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new product to the `products` collection.
  static Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection(CollectionNames.products).add(productData);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Update an existing product in the `products` collection.
  static Future<void> updateProduct(String productId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection(CollectionNames.products).doc(productId).update(newData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product from the `products` collection.
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(CollectionNames.products).doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Retrieve all products from the `products` collection.
  static Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firestore.collection(CollectionNames.products).get();
      return querySnapshot.docs.map((doc) {
        final productData = doc.data();
        productData['id'] = doc.id; // Add the document ID to the product data
        return Product.fromJson(productData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to retrieve products: $e');
    }
  }
}
