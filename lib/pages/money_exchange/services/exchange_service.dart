import 'package:ofoqe_naween/pages/money_exchange/models/exchange_model.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import '../../../services/firebase/firestore_base_service.dart';

class ExchangeService extends FirestoreBaseService<ExchangeModel> {
  ExchangeService() : super(CollectionNames.exchanges);

  /// Factory method to handle Customer-specific logic
  static ExchangeModel fromMap(Map<String, dynamic> map, String id) {
    return ExchangeModel.fromMap(map, id);
  }
}
