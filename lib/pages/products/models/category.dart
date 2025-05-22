import 'package:ofoqe_naween/models/base_model.dart';

class CategoryModel extends BaseModel {
  String? name; // Name of the category
  String? description; // Optional description of the category
  String? parentId; // Optional parent category ID

  CategoryModel({
    super.id,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.description,
    this.parentId,
  });

  /// Factory method to create a CategoryModel from a Firestore document
  factory CategoryModel.fromMap(Map<String, dynamic> map, String? id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String?,
      description: map['description'] as String?,
      parentId: map['parentId'] as String?,
      createdBy: map['createdBy'] as String?,
      updatedBy: map['updatedBy'] as String?,
      createdAt: BaseModel.parseTimestamp(map, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(map, 'updatedAt'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CategoryModel) return false;
    return id == other.id;
  }

  /// Convert CategoryModel to a Firestore-compatible map
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap(); // Get BaseModel's map
    map.addAll({
      'name': name,
      'description': description,
      'parentId': parentId,
    });
    return map;
  }
}
