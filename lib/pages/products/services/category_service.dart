import 'package:ofoqe_naween/pages/products/models/category.dart';
import 'package:ofoqe_naween/services/firebase/firestore_base_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';

class CategoryService extends FirestoreBaseService<CategoryModel> {
  CategoryService() : super(CollectionNames.categories);

  /// Factory method to handle Customer-specific logic
  static CategoryModel fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel.fromMap(map, id);
  }
}
