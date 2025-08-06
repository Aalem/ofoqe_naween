import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/products/models/category.dart';
import 'package:ofoqe_naween/pages/products/pages/add_category.dart';
import 'package:ofoqe_naween/pages/products/services/category_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/strings.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.categories),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(Strings.addCategory),
                content: const AddCategoryPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: GenericDataTable<CategoryModel>(
        columns: const [
          DataColumn(label: Text(Strings.number)),
          DataColumn(label: Text(Strings.categoryName)),
          DataColumn(label: Text(Strings.description)),
          DataColumn(label: Text(Strings.actions)),
        ],
        dataStream: CategoryService().getDocumentsStreamWithFilters(
          orderByField: 'name',
          descending: true,
        ),
        fromMap: (data, id) => CategoryModel.fromMap(data, id),
        deleteService: CategoryService().deleteDocument,
        addEditWidget: ({CategoryModel? model, String? id}) => AddCategoryPage(category: model, id: id),
        cellBuilder: (CategoryModel category) => [
          DataCell(Text(category.name!)),
          DataCell(Text(category.description ?? '')),
        ],
        addTitle: Strings.addCategory,
        deleteTitlePrefix: Strings.deleteCategory,
        deleteMessage: Strings.categoryDeleteMessage,
        deleteSuccessMessage: Strings.categoryDeletedSuccessfully,
        deleteFailureMessage: Strings.failedToDeleteCategory,
        enableSearch: false,
        enableSort: false,
        searchFields: [],
        sortFields: [],
      ),
    );
  }
}