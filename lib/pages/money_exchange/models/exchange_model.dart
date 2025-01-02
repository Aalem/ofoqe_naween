import 'package:ofoqe_naween/models/base_model.dart';

class ExchangeModel extends BaseModel {
  final String name;
  final String phoneNumber1;
  final String phoneNumber2;
  final String address;

  ExchangeModel({
    super.id,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.phoneNumber1,
    required this.phoneNumber2,
    required this.address,
  });

  // Factory method to create an ExchangeModel from a Firestore document snapshot
  factory ExchangeModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ExchangeModel(
      id: documentId,
      name: data['name'] ?? '',
      phoneNumber1: data['phoneNumber1'] ?? '',
      phoneNumber2: data['phoneNumber2'] ?? '',
      address: data['address'] ?? '',
      createdBy: data['createdBy'] ?? 'system',
      updatedBy: data['updatedBy'] ?? 'system',
      createdAt: BaseModel.parseTimestamp(data, 'createdAt'),
      updatedAt: BaseModel.parseTimestamp(data, 'updatedAt'),
    );
  }

  // Method to convert an ExchangeModel to a map to store in Firestore
  @override
  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'phoneNumber1' : phoneNumber1,
      'phoneNumber2' : phoneNumber2,
      'address' : address,
    };
  }
}
