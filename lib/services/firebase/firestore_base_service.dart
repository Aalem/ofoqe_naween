import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ofoqe_naween/models/base_model.dart';

abstract class FirestoreBaseService<T extends BaseModel> {
  final String collectionPath;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreBaseService(this.collectionPath);

  /// Get current user ID
  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user is currently logged in");
    }
  }

  /// Create a document
  Future<void> addDocument(T data) async {
    try {
      final now = DateTime.now();
      final currentUserId = 'developmentId';
      //TODO get the logged in user here
      // final currentUserId = _getCurrentUserId();

      // Prepare document data with additional metadata
      final documentData = data.toMap()
        ..addAll({
          'createdBy': currentUserId,
          'updatedBy': currentUserId,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

      await _firestore.collection(collectionPath).add(documentData);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  /// Fetch all documents
  Future<List<T>> getDocuments(
      T Function(Map<String, dynamic> map, String id) fromMap) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(collectionPath).get();

      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  /// Fetch a single document by ID
  Future<T?> getDocumentById(String id,
      T Function(Map<String, dynamic> map, String id) fromMap) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection(collectionPath).doc(id).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return fromMap(docSnapshot.data()!, docSnapshot.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch document by ID: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Update a document
  Future<void> updateDocument(String id, T data) async {
    try {
      final now = DateTime.now();

      final currentUserId = 'developmentId';
      //TODO get the logged in user here
      // final currentUserId = _getCurrentUserId();

      // Prepare updated document data with additional metadata
      final documentData = data.toMap()
        ..addAll({
          'updatedBy': currentUserId,
          'updatedAt': Timestamp.fromDate(now),
        });

      await _firestore.collection(collectionPath).doc(id).update(documentData);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
}
