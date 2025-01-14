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

  /// Fetch documents with filters
  Future<List<T>> getDocumentsWithFilters(
      T Function(Map<String, dynamic> map, String id) fromMap,
      {Map<String, dynamic>? filters,
        List<String>? orderByFields,
        bool descending = false}) async {
    try {
      Query<Map<String, dynamic>> query =
      _firestore.collection(collectionPath);

      // Apply filters
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((field, value) {
          if (value is List && value.length == 2 && value[0] == 'range') {
            // Range filter: [field, ['range', lowerBound, upperBound]]
            query = query.where(field, isGreaterThanOrEqualTo: value[1]);
            query = query.where(field, isLessThanOrEqualTo: value[2]);
          } else {
            // Equality filter
            query = query.where(field, isEqualTo: value);
          }
        });
      }

      // Apply ordering
      if (orderByFields != null && orderByFields.isNotEmpty) {
        for (String field in orderByFields) {
          query = query.orderBy(field, descending: descending);
        }
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents with filters: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentsStream() {
    return _firestore.collection(collectionPath).snapshots();
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentsStreamWithFilters({
        Map<String, dynamic>? filters,
        String? searchField, // Field to perform search on
        String? searchValue, // Value to search for
        String? orderByField, // Optional field to sort by
        bool descending = false, // Optional sorting order
      }) {
    CollectionReference<Map<String, dynamic>> collection =
    _firestore.collection(collectionPath);

    // Start with the base query
    Query<Map<String, dynamic>> query = collection;

    // Apply filters if provided
    if (filters != null) {
      for (var filter in filters.entries) {
        query = query.where(filter.key, isEqualTo: filter.value);
      }
    }

    // Apply search functionality if a search field and value are provided
    if (searchField != null && searchValue != null && searchValue.isNotEmpty) {
      query = query
          .where(searchField, isGreaterThanOrEqualTo: searchValue)
          .where(searchField, isLessThanOrEqualTo: searchValue + '\uf8ff');
    }

    // Apply sorting if an orderByField is provided
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    // Return the query snapshots as a stream
    return query.snapshots();
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
