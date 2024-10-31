// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
// import 'package:ofoqe_naween/components/no_data.dart';
// import 'package:ofoqe_naween/components/nothing_found.dart';
// import 'package:ofoqe_naween/screens/customers/add_customer.dart';
// import 'package:ofoqe_naween/screens/customers/collection_fields/customer_fields.dart';
// import 'package:ofoqe_naween/screens/customers/services/customer_service.dart';
// import 'package:ofoqe_naween/screens/customers/models/customer_model.dart';
// import 'package:ofoqe_naween/theme/colors.dart';
// import 'package:ofoqe_naween/values/collection_names.dart';
// import 'package:ofoqe_naween/values/strings.dart';
//
// class CustomersPage extends StatefulWidget {
//   const CustomersPage({super.key});
//
//   @override
//   _CustomersPageState createState() => _CustomersPageState();
// }
//
// class _CustomersPageState extends State<CustomersPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final int _pageSize = 11;
//   final TextEditingController _searchController = TextEditingController();
//   int _currentPage = 1;
//   Stream<QuerySnapshot<Map<String, dynamic>>>? _customerStream;
//   late DocumentSnapshot lastRecordedDocumentId;
//
//   final ScrollController _verticalController = ScrollController();
//   final ScrollController _horizontalController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _customerStream = _getCustomers();
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> _getCustomers(
//       {bool isSearching = false}) {
//     Query<Map<String, dynamic>> query =
//         _firestore.collection(CollectionNames.customers);
//
//     query = query.orderBy(CustomerFields.date, descending: true);
//
//     if (_currentPage > 1) {
//       query = query.startAfterDocument(lastRecordedDocumentId);
//     }
//
//     query = query.limit(isSearching ? 1 : _pageSize);
//
//     return query.snapshots();
//   }
//
//   void _handleNextPage() {
//     setState(() {
//       _currentPage++;
//       _customerStream = _getCustomers();
//     });
//   }
//
//   void _handlePreviousPage() {
//     if (_currentPage > 1) {
//       setState(() {
//         _currentPage--;
//         _customerStream = _getCustomers();
//       });
//     }
//   }
//
//   void _search() {
//     _currentPage = 1;
//     setState(() {
//       _customerStream = _getCustomers(isSearching: false);
//     });
//   }
//
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> getFilteredDocs(
//       QuerySnapshot<Map<String, dynamic>> snapshot) {
//     String searchText = _searchController.text.toLowerCase();
//     return snapshot.docs.where((doc) {
//       String company =
//           doc.data()[CustomerFields.company]?.toString().toLowerCase() ?? '';
//       String name =
//           doc.data()[CustomerFields.name]?.toString().toLowerCase() ?? '';
//
//       return company.contains(searchText) || name.contains(searchText);
//     }).toList();
//   }
//
//   Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
//     int number = (_currentPage - 1) * _pageSize;
//     if (snapshot.docs.isNotEmpty) {
//       var filteredDocs = snapshot.docs;
//       if (_searchController.text.isNotEmpty) {
//         filteredDocs = getFilteredDocs(snapshot);
//       }
//
//       if (filteredDocs.isNotEmpty) {
//         lastRecordedDocumentId = filteredDocs.last;
//         return Column(
//           children: [
//             const SizedBox(height: 10),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               child: DataTable(
//                 border: TableBorder.all(
//                   width: 0.1, // Adjust width as needed
//                   color: Colors.grey, // Change color to your preference
//                   style: BorderStyle.solid,
//                 ),
//                 headingTextStyle: Theme.of(context)
//                     .textTheme
//                     .bodyMedium
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 headingRowColor: WidgetStateColor.resolveWith(
//                     (states) => Theme.of(context).highlightColor),
//                 columns: const [
//                   DataColumn(label: Text(Strings.number)),
//                   DataColumn(label: Text(Strings.company)),
//                   DataColumn(label: Text(Strings.custoerName)),
//                   DataColumn(label: Text(Strings.phoneNumbers)),
//                   DataColumn(label: Text(Strings.address)),
//                   DataColumn(label: Text(Strings.edit)),
//                   DataColumn(label: Text(Strings.delete)),
//                 ],
//                 rows: filteredDocs.map((entry) {
//                   final customerEntry = Customer.fromMap(entry.data());
//                   number++;
//                   return DataRow(
//                     cells: [
//                       DataCell(ConstrainedBox(
//                           constraints: const BoxConstraints(maxWidth: 30),
//                           child: Text(number.toString()))),
//                       DataCell(Text(customerEntry.company)),
//                       DataCell(Text(customerEntry.name)),
//                       DataCell(Text(
//                           textDirection: TextDirection.ltr,
//                           '${customerEntry.phone1} ${customerEntry.phone2.isNotEmpty ? '\n${customerEntry.phone2}' : ''}')),
//                       DataCell(Text(customerEntry.address)),
//                       DataCell(
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.blue),
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text(Strings.addCustomerTitle),
//                                   content: NewCustomerPage(
//                                       customer: customerEntry, id: entry.id),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       DataCell(IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return ConfirmationDialog(
//                                 title: Strings.customerDeleteTitle +
//                                     customerEntry.name,
//                                 message: Strings.customerDeleteMessage,
//                                 onConfirm: () async {
//                                   try {
//                                     await CustomerService.deleteCustomer(
//                                         entry.id);
//                                     Navigator.of(context).pop();
//                                   } catch (e) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content:
//                                             Text('Failed to delete customer'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       )),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         );
//       } else {
//         return NothingFound();
//       }
//     } else {
//       return NoDataExists();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text(Strings.addCustomerTitle),
//                 content: NewCustomerPage(),
//               );
//             },
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//       appBar: AppBar(
//         title: const Row(
//           children: [
//             Expanded(
//                 child: Text(
//               Strings.customers,
//               textAlign: TextAlign.right,
//             )),
//           ],
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _customerStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return Column(
//             children: [
//               Container(
//                 color: AppColors.appBarBG,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: Strings.search,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     prefixIcon: IconButton(
//                       icon: const Icon(Icons.search),
//                       onPressed: () {
//                         // _search();
//                         setState(() {});
//                       },
//                     ),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         if (_searchController.text.isNotEmpty) {
//                           _searchController.clear();
//                           _search();
//                         }
//                       },
//                     ),
//                   ),
//                   onSubmitted: (value) {
//                     // _search();
//                     setState(() {});
//                   },
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Scrollbar(
//                     controller: _verticalController,
//                     thumbVisibility: true,
//                     child: SingleChildScrollView(
//                       controller: _verticalController,
//                       scrollDirection: Axis.vertical,
//                       child: Scrollbar(
//                         controller: _horizontalController,
//                         thumbVisibility: true,
//                         child: SingleChildScrollView(
//                           controller: _horizontalController,
//                           scrollDirection: Axis.horizontal,
//                           child: _buildDataTable(snapshot.data!),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Visibility(
//                       visible: _currentPage > 1,
//                       child: TextButton(
//                         onPressed: _handlePreviousPage,
//                         child: const Text(Strings.previous),
//                       ),
//                     ),
//                     const SizedBox(width: 10.0),
//                     Text('${Strings.page} $_currentPage'),
//                     const SizedBox(width: 10.0),
//                     Visibility(
//                       visible: snapshot.data!.docs.length == _pageSize,
//                       child: TextButton(
//                         onPressed: _handleNextPage,
//                         child: const Text(Strings.next),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/screens/customers/add_customer.dart';
import 'package:ofoqe_naween/screens/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/screens/customers/services/customer_service.dart';
import 'package:ofoqe_naween/screens/customers/models/customer_model.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

bool _updateTriggered = false;

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot<Map<String, dynamic>>>? _customerStream;

  int? _sortColumnIndex;
  bool _sortAscending = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _filteredDocs;

  @override
  void initState() {
    super.initState();
    _customerStream = _getCustomers();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCustomers() {
    return _firestore
        .collection(CollectionNames.customers)
        .orderBy(CustomerFields.name, descending: true)
        .snapshots();
  }

  void _search() {
    setState(() {
      _filteredDocs = null; // Reset filtered docs on new search
    });
  }

  void _sort<T>(Comparable<T> Function(Customer) getField, int columnIndex,
      bool ascending, QuerySnapshot<Map<String, dynamic>> snapshot) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      // Get the filtered list
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          getFilteredDocs(snapshot);

      // Sort the filtered docs
      docs.sort((a, b) {
        final fieldA = getField(Customer.fromMap(a.data()));
        final fieldB = getField(Customer.fromMap(b.data()));

        return ascending
            ? Comparable.compare(fieldA, fieldB)
            : Comparable.compare(fieldB, fieldA);
      });

      _filteredDocs = docs; // Update filtered docs after sorting
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> getFilteredDocs(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    String searchText = _searchController.text.toLowerCase();
    return snapshot.docs.where((doc) {
      String company =
          doc.data()[CustomerFields.company]?.toString().toLowerCase() ?? '';
      String name =
          doc.data()[CustomerFields.name]?.toString().toLowerCase() ?? '';

      return company.contains(searchText) || name.contains(searchText);
    }).toList();
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
                      (c) => c.company, columnIndex, ascending, snapshot),
                ),
                DataColumn(
                    label: const Text(Strings.customerName),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (c) => c.name, columnIndex, ascending, snapshot)),
                const DataColumn(label: Text(Strings.phoneNumbers)),
                const DataColumn(label: Text(Strings.address)),
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
                title: Text(Strings.addCustomerTitle),
                content: NewCustomerPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text(Strings.customers),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getCustomers(),
        builder: (context, snapshot) {
          if (_updateTriggered) {
            resetFilteredDocs(snapshot.data!);
            _updateTriggered = false;
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
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
                        borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _search(); // Trigger search
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                          _search(); // Reset search
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    _search(); // Trigger search on submit
                  },
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
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> customers;
  final BuildContext context;

  CustomerDataSource(this.customers, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= customers.length) {
      return const DataRow(cells: []);
    }
    final customerEntry = Customer.fromMap(customers[index].data());
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(customerEntry.company)),
        DataCell(Text(customerEntry.name)),
        DataCell(Text(
            textDirection: TextDirection.ltr,
            '${customerEntry.phone1} ${customerEntry.phone2.isNotEmpty ? '\n${customerEntry.phone2}' : ''}')),
        DataCell(Text(customerEntry.address)),
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
                        content: NewCustomerPage(
                            customer: customerEntry, id: customers[index].id),
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
                        title: Strings.customerDeleteTitle + customerEntry.name,
                        message: Strings.customerDeleteMessage,
                        onConfirm: () async {
                          try {
                            await CustomerService.deleteCustomer(
                                customers[index].id);
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete customer'),
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
  int get rowCount => customers.length;

  @override
  int get selectedRowCount => 0;

  int get rowHeight => 56; // Adjust as needed
}
