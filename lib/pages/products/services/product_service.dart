import 'package:ofoqe_naween/pages/products/models/product.dart';
import 'package:ofoqe_naween/services/firebase/firestore_base_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class ProductService extends FirestoreBaseService<Product> {

  ProductService() : super(CollectionNames.products);

  /// Factory method to handle Customer-specific logic
  static Product fromMap(Map<String, dynamic> map, String id) {
    return Product.fromMap(map, id);
  }
}
