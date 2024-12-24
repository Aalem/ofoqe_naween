import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // For formatted date

class FirestoreService {
  // Private constructor to prevent multiple instances
  FirestoreService._privateConstructor();

  // Static instance of the FirestoreService (singleton)
  static final FirestoreService instance = FirestoreService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String get _currentUserId {
    return _auth.currentUser?.uid ?? 'unknown';
  }

  // Format the current date and time
  String get _currentTimestamp {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  // Add common metadata to documents
  Map<String, dynamic> _getMetadata() {
    return {
      'createdBy': _currentUserId,
      'createdAt': _currentTimestamp,
      'updatedBy': _currentUserId,
      'updatedAt': _currentTimestamp,
    };
  }

  // Create a new document in Firestore
  Future<DocumentReference> create(String collection, Map<String, dynamic> data) async {
    try {
      // Add metadata to the data
      final dataWithMetadata = {...data, ..._getMetadata()};

      // Create the document
      final docRef = await _db.collection(collection).add(dataWithMetadata);
      return docRef;
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  // Update an existing document
  Future<void> update(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      // Add updated metadata
      final dataWithMetadata = {...data, 'updatedBy': _currentUserId, 'updatedAt': _currentTimestamp};

      // Update the document
      await _db.collection(collection).doc(documentId).update(dataWithMetadata);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  // Delete a document
  Future<void> delete(String collection, String documentId) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // Get a single document by its ID
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      return await _db.collection(collection).doc(documentId).get();
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  // Get a list of documents from a collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _db.collection(collection).get();
    } catch (e) {
      print('Error getting collection: $e');
      rethrow;
    }
  }

  // Listen to real-time updates of a document
  Stream<DocumentSnapshot> listenToDocument(String collection, String documentId) {
    return _db.collection(collection).doc(documentId).snapshots();
  }

  // Listen to real-time updates of a collection
  Stream<QuerySnapshot> listenToCollection(String collection) {
    return _db.collection(collection).snapshots();
  }
}
