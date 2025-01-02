import 'package:ofoqe_naween/pages/customers/models/customer_model.dart';
import 'package:ofoqe_naween/services/firebase/firestore_base_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class CustomerService extends FirestoreBaseService<Customer> {
  CustomerService() : super(CollectionNames.customers);

  /// Factory method to handle Customer-specific logic
  static Customer fromMap(Map<String, dynamic> map, String id) {
    return Customer.fromMap(map, id);
  }

}
