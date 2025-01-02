import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

abstract class BaseModel {
  final String? id;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BaseModel({
     this.id,
     this.createdBy,
     this.updatedBy,
     this.createdAt,
     this.updatedAt,
  });

  // Factory method to convert Firestore map to model instance
  factory BaseModel.fromMap(Map<String, dynamic> map) {
    throw UnimplementedError("fromMap() must be implemented in subclasses");
  }

  // Method to convert model to map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Handle the case where createdAt or updatedAt might be missing or null
  static DateTime? parseTimestamp(Map<String, dynamic> map, String fieldName) {
    if (map[fieldName] == null) {
      return null; // Return null if the timestamp is missing
    }
    // Parse the timestamp from Firestore into a DateTime object
    return (map[fieldName] is Timestamp)
        ? (map[fieldName] as Timestamp).toDate()
        : DateTime.tryParse(map[fieldName].toString());
  }
}
