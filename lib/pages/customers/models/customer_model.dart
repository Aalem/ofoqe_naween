import 'package:ofoqe_naween/models/base_model.dart';

class Customer extends BaseModel {
  late String name;
  late String company;
  late String email;
  late String phone1;
  late String phone2;
  late String address;

  Customer({
    super.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone1,
    required this.phone2,
    required this.address,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
  });

  // Factory constructor to create a Customer object from a Map
  factory Customer.fromMap(Map<String, dynamic> map, String id) {
    return Customer(
      id: id,
      name: map['name'] ?? '',
      company: map['company'] ?? '',
      email: map['email'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      address: map['address'] ?? '',
      createdBy: map['createdBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      createdAt: BaseModel.parseTimestamp(map, 'createdAt') ?? DateTime.now(),
      updatedAt: BaseModel.parseTimestamp(map, 'updatedAt') ?? DateTime.now(),
    );
  }

  // Convert the Customer object to a Map
  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'email': email,
      'phone1': phone1,
      'phone2': phone2,
      'address': address,
    };
  }
}
