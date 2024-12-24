
abstract class BaseModel {
  final String id;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
