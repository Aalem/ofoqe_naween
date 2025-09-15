import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/products/collection_fields/product_fields.dart';
import 'package:ofoqe_naween/pages/products/models/product.dart';
import 'package:ofoqe_naween/pages/products/pages/add_product.dart';
import 'package:ofoqe_naween/pages/products/services/product_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _productStream;

  @override
  void initState() {
    super.initState();
    _productStream = _getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getProducts() {
    return ProductService().getDocumentsStreamWithFilters(
      orderByField: ProductFields.name,
      descending: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.products),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text(Strings.addProduct),
              content: AddProductPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: GenericDataTable<Product>(
        columns: const [
          DataColumn(label: Text(Strings.number)),
          DataColumn(label: Text(Strings.productName)),
          DataColumn(label: Text(Strings.productCode)),
          DataColumn(label: Text(Strings.category)),
          DataColumn(label: Text(Strings.brand)),
          DataColumn(label: Text(Strings.model)),
          DataColumn(label: Text(Strings.warranty)),
          DataColumn(label: Text(Strings.color)),
          DataColumn(label: Text(Strings.unit)),
          DataColumn(label: Text(Strings.dimension)),
          DataColumn(label: Text(Strings.weight)),
          DataColumn(label: Text(Strings.actions)),
        ],
        dataStream: _productStream!,
        fromMap: (data, id) => Product.fromMap(data, id),
        deleteService: ProductService().deleteDocument,
        addEditWidget: ({Product? model, String? id}) =>
            AddProductPage(product: model, id: id),
        cellBuilder: (Product product) => [
          DataCell(Text(product.name ?? '')),
          DataCell(Text(product.code ?? '')),
          DataCell(Text(product.categoryName ?? '')),
          DataCell(Text(product.brandName ?? '')),
          DataCell(Text(product.unit ?? '')),
          DataCell(Text(product.model ?? '')),
          DataCell(Text(product.warranty ?? '')),
          DataCell(Text(product.color ?? '')),
          DataCell(Text(product.dimension ?? '')),
          DataCell(Text(product.weight?.toString() ?? '')),
        ],
        addTitle: Strings.addProduct,
        deleteTitlePrefix: Strings.delete + Strings.product,
        deleteMessage: Strings.deleteItemMessage,
        deleteSuccessMessage: Strings.product + Strings.itemDeletedSuccessfully,
        deleteFailureMessage: Strings.failedToDeleteItem + Strings.product,
        enableSearch: true,
        enableSort: true,
        searchFields: const [
          ProductFields.name,
          ProductFields.code,
          ProductFields.categoryName,
          ProductFields.brandName,
          ProductFields.model,
        ],
        sortFields: [
              (Product p) => p.name ?? '',
              (Product p) => p.code ?? '',
              (Product p) => p.categoryName ?? '',
              (Product p) => p.brandName ?? '',
              (Product p) => p.model ?? '',
        ],
      ),
    );
  }
}
