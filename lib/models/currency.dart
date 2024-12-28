import 'package:ofoqe_naween/models/base_model.dart';

class Currency extends BaseModel {
  final String name;
  final String symbol;

  Currency({
    required super.id,
    required this.name,
    required this.symbol,
    required super.createdBy,
    required super.updatedBy,
    super.createdAt,
    super.updatedAt,
  });

  // Factory method to convert Firestore map to Currency model
  factory Currency.fromMap(Map<String, dynamic> map, String id) {
    return Currency(
      id: id ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      createdBy: map['createdBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      createdAt: BaseModel.parseTimestamp(map, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(map, 'updatedAt'),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'name': name,
      'symbol': symbol,
    };
  }
}
