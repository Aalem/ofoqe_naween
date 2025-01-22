import 'package:ofoqe_naween/models/base_model.dart';

class Product extends BaseModel {
  String? name;
  String? code;
  String? categoryId;
  String? unit;
  String? description;
  String? warranty;
  String? brand;
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
    this.unit,
    this.description,
    this.warranty,
    this.brand,
    this.model,
    this.dimension,
    this.weight,
    this.color,
    this.metadata,
  });

  /// Factory constructor to create a Product from a JSON map
  factory Product.fromMap(Map<String, dynamic> json, String? id) {
    return Product(
      id: id,
      name: json['name'] as String?,
      code: json['code'] as String?,
      categoryId: json['categoryId'] as String?,
      unit: json['unit'] as String?,
      description: json['description'] as String?,
      warranty: json['warranty'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      dimension: json['dimension'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      color: json['color'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: BaseModel.parseTimestamp(json, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(json, 'updatedAt'),
    );
  }

  /// Convert Product to a Firestore-compatible map
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap(); // Get BaseModel's map
    map.addAll({
      'name': name,
      'code': code,
      'categoryId': categoryId,
      'unit': unit,
      'description': description,
      'warranty': warranty,
      'brand': brand,
      'model': model,
      'dimension': dimension,
      'weight': weight,
      'color': color,
      'metadata': metadata,
    });
    return map;
  }
}
