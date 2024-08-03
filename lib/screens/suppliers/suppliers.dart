import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/components/texts/appbar_title.dart';
import 'package:ofoqe_naween/screens/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/screens/suppliers/add_supplier.dart';
import 'package:ofoqe_naween/screens/suppliers/collection_fields/supplier_fields.dart';
import 'package:ofoqe_naween/screens/suppliers/models/supplier_model.dart';
import 'package:ofoqe_naween/screens/suppliers/services/supplier_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _supplierStream;
  late DocumentSnapshot lastRecordedDocumentId;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

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

    if (_currentPage > 1) {
      query = query.startAfterDocument(lastRecordedDocumentId);
    }

    query = query.limit(isSearching ? 1 : _pageSize);

    return query.snapshots();
  }

  void _handleNextPage() {
    setState(() {
      _currentPage++;
      _supplierStream = _getSuppliers();
    });
  }

  void _handlePreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _supplierStream = _getSuppliers();
      });
    }
  }

  void _search() {
    _currentPage = 1;
    setState(() {
      _supplierStream = _getSuppliers(isSearching: false);
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

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number = (_currentPage - 1) * _pageSize;
    if (snapshot.docs.isNotEmpty) {
      var filteredDocs = snapshot.docs;
      if (_searchController.text.isNotEmpty) {
        filteredDocs = getFilteredDocs(snapshot);
      }

      if (filteredDocs.isNotEmpty) {
        lastRecordedDocumentId = filteredDocs.last;
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: DataTable(
                border: TableBorder.all(
                  width: 0.1, // Adjust width as needed
                  color: Colors.grey, // Change color to your preference
                  style: BorderStyle.solid,
                ),
                headingTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Theme.of(context).highlightColor),
                columns: const [
                  DataColumn(label: Text(Strings.number)),
                  DataColumn(label: Text(Strings.supplier)),
                  DataColumn(label: Text(Strings.products)),
                  DataColumn(label: Text(Strings.phoneNumbers)),
                  DataColumn(label: Text(Strings.address)),
                  DataColumn(label: Text(Strings.email)),
                  DataColumn(label: Text(Strings.website)),
                  DataColumn(label: Text(Strings.edit)),
                  DataColumn(label: Text(Strings.delete)),
                ],
                rows: filteredDocs.map((entry) {
                  final supplierEntry = Supplier.fromMap(entry.data());
                  number++;
                  return DataRow(
                    cells: [
                      DataCell(ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 30),
                          child: Text(number.toString()))),
                      DataCell(Text(supplierEntry.name)),
                      DataCell(Text(supplierEntry.products)),
                      DataCell(Text(
                          textDirection: TextDirection.ltr,
                          '${supplierEntry.phone1} ${supplierEntry.phone2.isNotEmpty ? '\n${supplierEntry.phone2}' : ''}')),
                      DataCell(Text(supplierEntry.address)),
                      DataCell(Text(supplierEntry.email)),
                      DataCell(Text(supplierEntry.website)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    title: const Text(Strings.addCustomerTitle),
                                    content: AddSupplierPage(
                                        supplier: supplierEntry, id: entry.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialog(
                                title: Strings.supplierDeleteTitle +
                                    supplierEntry.name,
                                message: Strings.supplierDeleteMessage,
                                onConfirm: () async {
                                  try {
                                    await SupplierService.deleteSupplier(
                                        entry.id);
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            Strings.failedToDeleteSupplier),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      } else {
        return NothingFound();
      }
    } else {
      return NoDataExists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text(Strings.addSupplierTitle),
                  content: AddSupplierPage(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Align(alignment: Alignment.centerRight, child: AppbarTitle(title: Strings.supplier)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _supplierStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
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
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // _search();
                          setState(() {});
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            _searchController.clear();
                            _search();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      // _search();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        scrollDirection: Axis.vertical,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: _buildDataTable(snapshot.data!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: _currentPage > 1,
                        child: TextButton(
                          onPressed: _handlePreviousPage,
                          child: const Text(Strings.previous),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text('${Strings.page} $_currentPage'),
                      const SizedBox(width: 10.0),
                      Visibility(
                        visible: snapshot.data!.docs.length == _pageSize,
                        child: TextButton(
                          onPressed: _handleNextPage,
                          child: const Text(Strings.next),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
