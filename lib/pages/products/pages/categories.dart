import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/pages/products/collection_fields/category_fields.dart';
import 'package:ofoqe_naween/pages/products/models/category.dart';
import 'package:ofoqe_naween/pages/products/pages/add_category.dart';
import 'package:ofoqe_naween/pages/products/services/category_service.dart';
import 'package:ofoqe_naween/values/strings.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final int _pageSize = 10;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  int _rowsPerPage = 13;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _exchangeStream;

  @override
  void initState() {
    super.initState();
    _exchangeStream = _getCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCategories() {
    return CategoryService().getDocumentsStreamWithFilters(
      // filters: {'name': _searchController.text, 'parentId': null},
      // searchField: 'name', // Field to search
      // searchValue: _searchController.text, // Search value
      orderByField: 'name', // Optional sorting
      descending: true, // Optional sorting order
    );

  }

  Widget _buildPaginatedDataTable(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number = 1;
    if (snapshot.docs.isNotEmpty) {
      var filteredDocs = snapshot.docs;
      _rowsPerPage = 12;
      _rowsPerPage = filteredDocs.length < _rowsPerPage
          ? filteredDocs.length
          : _rowsPerPage;
      return Theme(
          data: Theme.of(context).copyWith(
            cardTheme: Theme.of(context).cardTheme.copyWith(
                elevation: 0, margin: EdgeInsets.zero, color: Colors.white),
          ),
          child: SizedBox(
              width: double.infinity,
              child: PaginatedDataTable(
                // header: Text(Strings.moneyExchanges),
                showEmptyRows: false,
                rowsPerPage: _rowsPerPage,
                // onRowsPerPageChanged: (value) {
                //   setState(() {
                //     _rowsPerPage = value!;
                //   });
                // },
                // availableRowsPerPage: const [5, 13, 20],
                horizontalMargin: 10,
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text(Strings.number)),
                  DataColumn(label: Text(Strings.categoryName)),
                  DataColumn(label: Text(Strings.description)),
                  DataColumn(label: Text(Strings.actions)),
                ],
                source: _DataTableSource(
                  context: context,
                  categories: filteredDocs,
                  numberOffset: (number - 1) * _rowsPerPage,
                ),
              )));
    } else {
      return NoDataExists();
    }
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
                title: Text(Strings.addCategory),
                content: AddCategoryPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _exchangeStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
              child: _buildPaginatedDataTable(snapshot.data!));
        },
      ),
    );
  }
}

class _DataTableSource extends DataTableSource {
  final BuildContext context;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> categories;
  final int numberOffset;

  _DataTableSource({
    required this.context,
    required this.categories,
    required this.numberOffset,
  });

  @override
  DataRow getRow(int index) {
    final categoryEntry = categories[index].data();
    int number = numberOffset + index + 1;

    return DataRow(cells: [
      DataCell(Text(number.toString())),
      DataCell(Text(categoryEntry[CategoryFields.name] ?? '')),
      DataCell(Text(categoryEntry[CategoryFields.description] ?? '')),
      DataCell(
        PopupMenuButton<int>(
          onSelected: (i) {
            switch (i) {
              case 1:
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(Strings.editExchange),
                      content: AddCategoryPage(
                          category: CategoryModel.fromMap(categoryEntry,
                              id: categories[index].id),
                          id: categories[index].id),
                    );
                  },
                );
                break;
              case 2:
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      title: Strings.deleteCategory +
                          (categoryEntry[CategoryFields.name] ?? ''),
                      message: Strings.categoryDeleteMessage,
                      onConfirm: () async {
                        // Save the scaffold messenger context
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        // Close the dialog before performing async operation
                        Navigator.of(context).pop();

                        try {
                          // Attempt to delete the exchange
                          await CategoryService().deleteDocument(
                              categories[index].id);

                          // If successful, show a success message
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content:
                                  Text(Strings.categoryDeletedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          // Handle any error (like related transactions) and show a SnackBar
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(Strings.failedToDeleteCategory),
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
    ]);
  }

  @override
  int get rowCount => categories.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
