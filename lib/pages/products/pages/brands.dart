import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/products/collection_fields/brand_fields.dart';
import 'package:ofoqe_naween/pages/products/models/brand.dart';
import 'package:ofoqe_naween/pages/products/pages/add_brand.dart';
import 'package:ofoqe_naween/pages/products/services/brand_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/strings.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  _BrandsPageState createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _brandStream;

  @override
  void initState() {
    super.initState();
    _brandStream = _getBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getBrands() {
    return BrandService().getDocumentsStreamWithFilters(
      orderByField: 'name',
      descending: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.brands),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text(Strings.add + Strings.brand),
                content: AddBrandPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: GenericDataTable<BrandModel>(
        columns: const [
          DataColumn(label: Text(Strings.number)),
          DataColumn(label: Text(Strings.brandName)),
          DataColumn(label: Text(Strings.description)),
          DataColumn(label: Text(Strings.country)),
          DataColumn(label: Text(Strings.actions)),
        ],
        dataStream: _brandStream!,
        fromMap: (data, id) => BrandModel.fromMap(data, id),
        deleteService: BrandService().deleteDocument,
        addEditWidget: ({BrandModel? model, String? id}) => AddBrandPage(brand: model, id: id),
        cellBuilder: (BrandModel brand) => [
          DataCell(Text(brand.name ?? '')),
          DataCell(Text(brand.description ?? '')),
          DataCell(Text(brand.country ?? '')),
        ],
        addTitle: Strings.add + Strings.brand,
        deleteTitlePrefix: Strings.delete,
        deleteMessage: Strings.deleteItemMessage,
        deleteSuccessMessage: Strings.brand + Strings.itemDeletedSuccessfully,
        deleteFailureMessage: Strings.failedToDeleteItem + Strings.brand,
        enableSearch: true,
        enableSort: true,
        searchFields: [BrandFields.name],
        sortFields: [
              (BrandModel b) => b.name ?? '',
              (BrandModel b) => b.description ?? '',
              (BrandModel b) => b.country ?? '',
        ],
      ),
    );
  }
}