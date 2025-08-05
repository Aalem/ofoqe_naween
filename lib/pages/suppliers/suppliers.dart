import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/suppliers/add_supplier.dart';
import 'package:ofoqe_naween/pages/suppliers/collection_fields/supplier_fields.dart';
import 'package:ofoqe_naween/pages/suppliers/models/supplier_model.dart';
import 'package:ofoqe_naween/pages/suppliers/services/supplier_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _supplierStream;

  @override
  void initState() {
    super.initState();
    _supplierStream = _getSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getSuppliers() {
    return _firestore
        .collection(CollectionNames.suppliers)
        .orderBy(SupplierFields.name, descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(Strings.suppliers),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text(Strings.addSupplierTitle),
                content: AddSupplierPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: GenericDataTable<Supplier>(
        columns: const [
          DataColumn(label: Text(Strings.number)), // Non-sortable
          DataColumn(label: Text(Strings.company)),
          DataColumn(label: Text(Strings.supplierProducts)),
          DataColumn(label: Text(Strings.phoneNumbers)),
          DataColumn(label: Text(Strings.address)),
          DataColumn(label: Text(Strings.website)),
          DataColumn(label: Text(Strings.email)),
          DataColumn(label: Text(Strings.actions)), // Non-sortable
        ],
        dataStream: _supplierStream!,
        fromMap: (data, id) => Supplier.fromMap(data),
        deleteService: SupplierService.deleteSupplier,
        addEditWidget: ({Supplier? model, String? id}) => AddSupplierPage(supplier: model, id: id),
        cellBuilder: (Supplier supplier) => [
          DataCell(Text(supplier.name)),
          DataCell(Text(supplier.products)),
          DataCell(
            Text(
              '${supplier.phone1}${supplier.phone2.isNotEmpty == true ? '\n${supplier.phone2}' : ''}',
              textDirection: TextDirection.ltr,
            ),
          ),
          DataCell(Text(supplier.address)),
          DataCell(Text(supplier.website)),
          DataCell(Text(supplier.email)),
        ],
        addTitle: Strings.addSupplierTitle,
        deleteTitlePrefix: Strings.supplierDeleteTitle,
        deleteMessage: Strings.supplierDeleteMessage,
        deleteSuccessMessage: Strings.supplierDeleteMessage,
        deleteFailureMessage: Strings.failedToDeleteSupplier,
        enableSearch: true,
        enableSort: true,
        searchFields: const [SupplierFields.products, SupplierFields.name],
        sortFields: [
              (Supplier s) => s.name,
              (Supplier s) => s.address,
        ],
      ),
    );
  }
}