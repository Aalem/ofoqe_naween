import 'package:ofoqe_naween/models/base_model.dart';

class Product extends BaseModel {
  String? name;
  String? code;
  String? categoryId;
  String? categoryName; // Cached category name
  String? unit;
  String? description;
  String? warranty;
  String? brandId;
  String? brandName; // Cached brand name
  String? model;
  String? dimension;
  double? weight;
  String? color;
  Map<String, dynamic>? metadata;

  Product({
    super.id,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.code,
    this.categoryId,
    this.categoryName,
    this.unit,
    this.description,
    this.warranty,
    this.brandId,
    this.brandName,
    this.model,
    this.dimension,
    this.weight,
    this.color,
    this.metadata,
  });

  /// Factory constructor to create a Product from a Firestore map
  factory Product.fromMap(Map<String, dynamic> map, String? id) {
    return Product(
      id: id,
      name: map['name'] as String?,
      code: map['code'] as String?,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?, // Cached category name
      unit: map['unit'] as String?,
      description: map['description'] as String?,
      warranty: map['warranty'] as String?,
      brandId: map['brandId'] as String?,
      brandName: map['brandName'] as String?, // Cached brand name
      model: map['model'] as String?,
      dimension: map['dimension'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      color: map['color'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdBy: map['createdBy'] as String?,
      updatedBy: map['updatedBy'] as String?,
      createdAt: BaseModel.parseTimestamp(map, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(map, 'updatedAt'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Product) return false;
    return id == other.id;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'name': name,
      'code': code,
      'categoryId': categoryId,
      'categoryName': categoryName, // Cached category name
      'unit': unit,
      'description': description,
      'warranty': warranty,
      'brandId': brandId,
      'brandName': brandName, // Cached brand name
      'model': model,
      'dimension': dimension,
      'weight': weight,
      'color': color,
      'metadata': metadata,
    });
    return map;
  }
}
