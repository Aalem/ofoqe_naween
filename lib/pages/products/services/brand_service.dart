import 'package:ofoqe_naween/pages/products/models/brand.dart';
import 'package:ofoqe_naween/services/firebase/firestore_base_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class BrandService extends FirestoreBaseService<BrandModel> {
  BrandService() : super(CollectionNames.brands);

  /// Factory method to handle Customer-specific logic
  static BrandModel fromMap(Map<String, dynamic> map, String id) {
    return BrandModel.fromMap(map, id);
  }
}
