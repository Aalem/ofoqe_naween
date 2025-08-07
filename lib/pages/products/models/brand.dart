import 'package:ofoqe_naween/models/base_model.dart';

class BrandModel extends BaseModel {
  String? name;
  String? description;
  String? country;

  BrandModel({
    super.id,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.description,
    this.country,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map, String? id) {
    return BrandModel(
      id: id,
      name: map['name'] as String?,
      description: map['description'] as String?,
      country: map['country'] as String?,
      createdBy: map['createdBy'] as String?,
      updatedBy: map['updatedBy'] as String?,
      createdAt: BaseModel.parseTimestamp(map, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(map, 'updatedAt'),
    );
  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    if (other is! BrandModel) return false;
    return id == other.id;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap(); // Get BaseModel's map
    map.addAll({
      'name': name,
      'description': description,
      'country': country,
    });
    return map;
  }
}
