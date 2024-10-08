class ExchangeModel {
  final String id; // UID, auto-generated by Firestore
  final String name;
  final String phoneNumber1;
  final String phoneNumber2;
  final String address;

  ExchangeModel({
    required this.id,
    required this.name,
    required this.phoneNumber1,
    required this.phoneNumber2,
    required this.address,
  });

  // Factory method to create an ExchangeModel from a Firestore document snapshot
  factory ExchangeModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ExchangeModel(
      id: documentId,
      name: data['name'] ?? '',
      phoneNumber1: data['phoneNumber1'] ?? '',
      phoneNumber2: data['phoneNumber2'] ?? '',
      address: data['address'] ?? '',
    );
  }

  // Method to convert an ExchangeModel to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'address': address,
    };
  }
}
