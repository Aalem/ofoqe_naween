import 'package:ofoqe_naween/models/currency.dart';
import 'package:ofoqe_naween/services/firebase/firestore_base_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class CurrencyService extends FirestoreBaseService<Currency> {
  CurrencyService() : super(CollectionNames.currencies);

  /// Factory method to handle Currency-specific logic
  static Currency fromMap(Map<String, dynamic> map, String id) {
    return Currency.fromMap(map, id);
  }
}
