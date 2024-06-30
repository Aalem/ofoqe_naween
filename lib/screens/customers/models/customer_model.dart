class Customer {
  late String name;
  late String company;
  late String email;
  late String date;
  late String phone1;
  late String phone2;
  late String address;

  Customer({
    required this.name,
    required this.company,
    required this.email,
    required this.date,
    required this.phone1,
    required this.phone2,
    required this.address,
  });

  // Factory constructor to create a Customer object from a Map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] ?? '',
      company: map['company'] ?? '',
      email: map['email'] ?? '',
      date: map['date'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      address: map['address'] ?? '',
    );
  }

  // Convert the Customer object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'email': email,
      'date': date,
      'phone1': phone1,
      'phone2': phone2,
      'address': address,
    };
  }
}
