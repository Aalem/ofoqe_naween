import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/components/texts/appbar_title.dart';
import 'package:ofoqe_naween/pages/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/pages/suppliers/add_supplier.dart';
import 'package:ofoqe_naween/pages/suppliers/collection_fields/supplier_fields.dart';
import 'package:ofoqe_naween/pages/suppliers/models/supplier_model.dart';
import 'package:ofoqe_naween/pages/suppliers/services/supplier_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

bool _updateTriggered = false;

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot<Map<String, dynamic>>>? _supplierStream;
  late DocumentSnapshot lastRecordedDocumentId;

  int? _sortColumnIndex;
  bool _sortAscending = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _filteredDocs;

  @override
  void initState() {
    super.initState();
    _supplierStream = _getSuppliers();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getSuppliers(
      {bool isSearching = false}) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(CollectionNames.suppliers);

    query = query.orderBy(SupplierFields.name, descending: true);

    query = query.limit(isSearching ? 1 : _pageSize);

    return query.snapshots();
  }

  void _search() {
    setState(() {
      _filteredDocs = null;
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> getFilteredDocs(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    String searchText = _searchController.text.toLowerCase();
    return snapshot.docs.where((doc) {
      String products = doc.data()[SupplierFields.products] ?? '';
      String name = doc.data()[CustomerFields.name].toString();

      return products.contains(searchText) || name.contains(searchText);
    }).toList();
  }

  void _sort<T>(Comparable<T> Function(Supplier) getField, int columnIndex,
      bool ascending, QuerySnapshot<Map<String, dynamic>> snapshot) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      // Get the filtered list
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          getFilteredDocs(snapshot);

      // Sort the filtered docs
      docs.sort((a, b) {
        final fieldA = getField(Supplier.fromMap(a.data()));
        final fieldB = getField(Supplier.fromMap(b.data()));

        return ascending
            ? Comparable.compare(fieldA, fieldB)
            : Comparable.compare(fieldB, fieldA);
      });

      _filteredDocs = docs; // Update filtered docs after sorting
    });
  }

  void resetFilteredDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    _filteredDocs = getFilteredDocs(snapshot);
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (_filteredDocs == null ||
        _filteredDocs?.length != snapshot.docs.length) {
      _filteredDocs = getFilteredDocs(snapshot);
    }
    if (_filteredDocs!.isEmpty) {
      return NothingFound();
    }

    return Theme(
        data: Theme.of(context).copyWith(
          cardTheme: Theme.of(context).cardTheme.copyWith(
              elevation: 0, margin: EdgeInsets.zero, color: Colors.white),
        ),
        child: SizedBox(
            width: double.infinity,
            child: PaginatedDataTable(
              showEmptyRows: false,
              columns: [
                const DataColumn(label: Text(Strings.number), numeric: true),
                DataColumn(
                  label: const Text(Strings.company),
                  onSort: (columnIndex, ascending) => _sort<String>(
                      (s) => s.name, columnIndex, ascending, snapshot),
                ),
                const DataColumn(label: Text(Strings.supplierProducts)),
                const DataColumn(label: Text(Strings.phoneNumbers)),
                DataColumn(
                    label: const Text(Strings.address),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (c) => c.name, columnIndex, ascending, snapshot)),
                const DataColumn(label: Text(Strings.website)),
                const DataColumn(label: Text(Strings.email)),
                const DataColumn(label: Text(Strings.actions)),
              ],
              rowsPerPage: _filteredDocs!.length < _pageSize
                  ? _filteredDocs!.length
                  : _pageSize,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              source: CustomerDataSource(_filteredDocs!, context),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        title: const Align(
            alignment: Alignment.centerRight,
            child: AppbarTitle(title: Strings.suppliers)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _supplierStream,
        builder: (context, snapshot) {
          if (_updateTriggered) {
            if (snapshot.data != null) {
              resetFilteredDocs(snapshot.data!);
              _updateTriggered = false;
            }
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                color: AppColors.appBarBG,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Strings.search,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _search(),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                          _search();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) => _search(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildDataTable(snapshot.data!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomerDataSource extends DataTableSource {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> suppliers;
  final BuildContext context;

  CustomerDataSource(this.suppliers, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= suppliers.length) {
      return const DataRow(cells: []);
    }
    final supplier = Supplier.fromMap(suppliers[index].data());
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(supplier.name)),
        DataCell(Text(supplier.products)),
        DataCell(Text(
            textDirection: TextDirection.ltr,
            '${supplier.phone1} ${supplier.phone2.isNotEmpty ? '\n${supplier.phone2}' : ''}')),
        DataCell(Text(supplier.address)),
        DataCell(Text(supplier.website)),
        DataCell(Text(supplier.email)),
        DataCell(
          PopupMenuButton<int>(
            onSelected: (i) {
              switch (i) {
                case 1:
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(Strings.addCustomerTitle),
                        content: AddSupplierPage(
                            supplier: supplier, id: suppliers[index].id),
                      );
                    },
                  );
                  _updateTriggered = true;
                  break;
                case 2:
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: Strings.supplierDeleteTitle + supplier.name,
                        message: Strings.customerDeleteMessage,
                        onConfirm: () async {
                          try {
                            await SupplierService.deleteSupplier(
                                suppliers[index].id);
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(Strings.failedToDeleteSupplier),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue),
                  title: Text(Strings.edit),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(Strings.delete),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => suppliers.length;

  @override
  int get selectedRowCount => 0;

  int get rowHeight => 56; // Adjust as needed
}
