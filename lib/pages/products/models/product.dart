class Product {
  late String productId;
  late String name;
  late String code;
  late String categoryId;
  late String unit;
  late DateTime createdAt;
  late String createdBy;
  late String? description;
  late String? warranty;
  late String? brand;
  late String? model;
  late String? dimension;
  late double? weight;
  late DateTime? updatedAt;
  late String? color;
  late Map<String, dynamic>? metadata;

  Product({
    required this.productId,
    required this.name,
    required this.code,
    required this.categoryId,
    required this.unit,
    required this.createdAt,
    required this.createdBy,
    this.description,
    this.warranty,
    this.brand,
    this.model,
    this.dimension,
    this.weight,
    this.updatedAt,
    this.color,
    this.metadata,
  });

  // Factory constructor to create an instance from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      categoryId: json['categoryId'] as String,
      createdBy: json['createdBy'] as String,
      unit: json['unit'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      warranty: json['warranty'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      dimension: json['dimension'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      color: json['color'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Method to convert an instance into a JSON map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'code': code,
      'categoryId': categoryId,
      'createdBy': createdBy,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'warranty': warranty,
      'brand': brand,
      'model': brand,
      'dimension': dimension,
      'weight': weight,
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color,
      'metadata': metadata,
    };
  }
}
