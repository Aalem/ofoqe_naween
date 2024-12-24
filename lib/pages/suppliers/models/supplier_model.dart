class Supplier {
  late String name;
  late String products;
  late String email;
  late String website;
  late String phone1;
  late String phone2;
  late String address;

  Supplier({
    required this.name,
    required this.products,
    required this.email,
    required this.website,
    required this.phone1,
    required this.phone2,
    required this.address,
  });

  // Factory constructor to create a Customer object from a Map
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      name: map['name'] ?? '',
      products: map['products'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      address: map['address'] ?? '',
    );
  }

  // Convert the Customer object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'products': products,
      'email': email,
      'website': website,
      'phone1': phone1,
      'phone2': phone2,
      'address': address,
    };
  }
}
