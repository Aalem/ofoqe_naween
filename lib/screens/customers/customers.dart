import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/screens/customers/add_customer.dart';
import 'package:ofoqe_naween/values/strings.dart';

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _customerStream;
  late DocumentSnapshot lastRecordedDocumentId;

  @override
  void initState() {
    super.initState();
    _customerStream = _getCustomers();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCustomers(
      {bool isSearching = false}) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('customers');

    if (_searchController.text.isNotEmpty) {
      query = query
          .where('company', isGreaterThanOrEqualTo: _searchController.text)
          .where('company',
              isLessThanOrEqualTo: '${_searchController.text}\uf8ff');
      // String searchText = _searchController.text.toLowerCase();
      // List<String> searchTerms = searchText.split(" ");
      //
      // query = query.where('name', arrayContainsAny: searchTerms);
    }else{
      query = query.orderBy('date', descending: true);
    }

    // Apply pagination to the query
    if (_currentPage > 1) {
      // If it's not the first page, start the query after the last document of the previous page
      query = query.startAfterDocument(lastRecordedDocumentId);
    }

    query = query.limit(
        isSearching ? 1 : _pageSize); // Limit the number of documents per page

    return query.snapshots();
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> _searchCustomers(
  //     {bool isSearching = false}) {
  //   Query<Map<String, dynamic>> query = _firestore
  //       .collection('customers')
  //       .where('name', arrayContainsAny: ['شاهد', 'کبیر']).orderBy('name');
  //
  //   if (_currentPage > 1) {
  //     // If it's not the first page, start the query after the last document of the previous page
  //     query = query.startAfterDocument(lastRecordedDocumentId);
  //   }
  //
  //   query = query.limit(isSearching ? 1 : _pageSize);
  //
  //   return query.snapshots();
  // }

  void _handleNextPage() {
    setState(() {
      _currentPage++;
      _customerStream = _getCustomers();
    });
  }

  void _handlePreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _customerStream = _getCustomers();
      });
    }
  }

  void _search() {
    _currentPage = 1;
    setState(() {
      _customerStream = _getCustomers(isSearching: false);
    });
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number =
        (_currentPage - 1) * _pageSize; // Calculate the starting number
    if (snapshot.docs.isNotEmpty) {
      lastRecordedDocumentId = snapshot.docs.last;
      return Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: DataTable(
              // dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey),

              headingTextStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).highlightColor),
              columns: const [
                DataColumn(label: Text(Strings.number)),
                DataColumn(label: Text(Strings.company)),
                DataColumn(label: Text(Strings.name)),
                DataColumn(label: Text(Strings.phoneNumbers)),
                DataColumn(label: Text(Strings.email)),
                DataColumn(label: Text(Strings.address)),
                DataColumn(label: Text(Strings.edit)),
                DataColumn(label: Text(Strings.delete)),
              ],
              rows: snapshot.docs.map((entry) {
                final customerEntry = entry.data();
                customerEntry['id'] = entry.id;
                number++;
                return DataRow(
                  cells: [
                    DataCell(Text(number.toString())),
                    DataCell(Text(customerEntry['company'] ?? '')),
                    DataCell(Text(customerEntry['name'] ?? '')),
                    DataCell(Text(
                        '${customerEntry["phone1"]} ${customerEntry["phone2"].isNotEmpty ? '\n${customerEntry["phone2"]}' : ''}'
                    )),
                    DataCell(Text(customerEntry['email'] ?? '')),
                    DataCell(Text(customerEntry['address'] ?? '')),
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
                                  content: NewCustomerPage(customerData: customerEntry), // Your AddLedgerEntry widget here
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
                        // Implement delete functionality here
                        // You can show a confirmation dialog and
                        // delete the customer document from Firestore
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialog(
                                title: Strings.dialogDeleteTitle +
                                    customerEntry['name'],
                                message: Strings.dialogDeleteMessage,
                                onConfirm: () {
                                  // Delete the customer document from Firestore
                                  Navigator.of(context).pop();
                                  FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(entry
                                          .id) // Assuming 'entry.id' contains the document ID
                                      .delete()
                                      .then((_) {
                                    // Close the dialog
                                  }).catchError((error) {
                                    // Show an error message
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Failed to delete customer'),
                                      backgroundColor: Colors.red,
                                    ));
                                  });
                                },
                              );
                            });
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
      return const Text(
        Strings.customerNotFound,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
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
                  title: Text(Strings.addCustomerTitle),
                  content: NewCustomerPage(), // Your AddLedgerEntry widget here
                ),
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
        stream: _customerStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final customerData = snapshot.data!.docs;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: Strings.searchByName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _search();
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
                      _search();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      // Enable vertical scrolling
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildDataTable(snapshot.data!),
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
                        visible: customerData.length == _pageSize,
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
