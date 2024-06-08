// import 'package:dari_datetime_picker/dari_datetime_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
// import 'package:ofoqe_naween/screens/money_exchange/add_transaction.dart';
// import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
// import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
// import 'package:ofoqe_naween/theme/colors.dart';
// import 'package:ofoqe_naween/utilities/formatter.dart';
// import 'package:ofoqe_naween/values/strings.dart';
// import 'package:intl/intl.dart' as intl;
//
// class MoneyExchange extends StatefulWidget {
//   @override
//   _MoneyExchangeState createState() => _MoneyExchangeState();
// }
//
// class _MoneyExchangeState extends State<MoneyExchange> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final int _pageSize = 11;
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _dateRangeController = TextEditingController();
//   final TextEditingController _specificDateController = TextEditingController();
//   final ScrollController _verticalScrollController = ScrollController();
//   final ScrollController _horizontalScrollController = ScrollController();
//   bool _showFilters = false;
//   bool _isDebitChecked = false;
//   bool _isCreditChecked = false;
//   int _currentPage = 1;
//   Stream<QuerySnapshot<Map<String, dynamic>>>? _transactionStream;
//   late DocumentSnapshot lastRecordedDocumentId;
//   DateTimeRange? _selectedDateRange;
//
//   @override
//   void initState() {
//     super.initState();
//     _transactionStream = _getTransactions();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _dateRangeController.dispose();
//     _specificDateController.dispose();
//     _verticalScrollController.dispose();
//     _horizontalScrollController.dispose();
//     super.dispose();
//   }
//   Stream<QuerySnapshot<Map<String, dynamic>>> _getTransactions({
//     bool isSearching = false,
//   }) {
//     Query<Map<String, dynamic>> query = _firestore.collection('money_exchange');
//
//     // Apply search filter if needed
//     if (_searchController.text.isNotEmpty) {
//       query = query
//           .where('description', isGreaterThanOrEqualTo: _searchController.text)
//           .where('description',
//           isLessThanOrEqualTo: '${_searchController.text}\uf8ff');
//     }
//
//     // Filter by debit/credit if a checkbox is selected
//     if (_isDebitChecked) {
//       query = query.where('debit', isGreaterThan: 0);
//     } else if (_isCreditChecked) {
//       query = query.where('credit', isGreaterThan: 0);
//     }
//
//     // Apply date filtering (specific or range)
//     if (_specificDateController.text.isNotEmpty) {
//       DateTime specificDate = DateTime.parse(_specificDateController.text);
//       query = query.where('gregorian_date', isEqualTo: specificDate);
//     } else if (_selectedDateRange != null) {
//       query = query
//           .where('date', isGreaterThanOrEqualTo: _selectedDateRange!.start)
//           .where('date', isLessThanOrEqualTo: _selectedDateRange!.end);
//     }
//
//     // Now that filtering is complete, order by date (if needed)
//     if (_specificDateController.text.isEmpty && _selectedDateRange == null && !(_isDebitChecked || _isCreditChecked)) {
//       // Only order by date if no other filtering is applied
//       query = query.orderBy('date', descending: true);
//     }
//
//     // Pagination logic (unchanged)
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
//       _transactionStream = _getTransactions();
//     });
//   }
//
//   void _handlePreviousPage() {
//     if (_currentPage > 1) {
//       setState(() {
//         _currentPage--;
//         _transactionStream = _getTransactions();
//       });
//     }
//   }
//
//   void _search() {
//     _currentPage = 1;
//     setState(() {
//       _transactionStream = _getTransactions(isSearching: false);
//     });
//   }
//
//   void _clearFilters() {
//     setState(() {
//       _searchController.clear();
//       _dateRangeController.clear();
//       _specificDateController.clear();
//       _isDebitChecked = false;
//       _isCreditChecked = false;
//       _selectedDateRange = null;
//       _currentPage = 1;
//       _transactionStream = _getTransactions(isSearching: false);
//     });
//   }
//
//   Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
//     int number = (_currentPage - 1) * _pageSize;
//     if (snapshot.docs.isNotEmpty) {
//       lastRecordedDocumentId = snapshot.docs.last;
//       return Column(
//         children: [
//           const SizedBox(height: 10),
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             child: DataTable(
//               border: TableBorder.all(
//                 width: 0.1,
//                 color: Colors.grey,
//                 style: BorderStyle.solid,
//               ),
//               headingTextStyle: Theme.of(context)
//                   .textTheme
//                   .bodyMedium
//                   ?.copyWith(fontWeight: FontWeight.bold),
//               headingRowColor: MaterialStateColor.resolveWith(
//                       (states) => Theme.of(context).highlightColor),
//               columns: const [
//                 DataColumn(label: Text(Strings.number)),
//                 DataColumn(label: Text(Strings.jalaliDate)),
//                 DataColumn(label: Text(Strings.gregorianDate)),
//                 DataColumn(label: Text(Strings.description)),
//                 DataColumn(label: Text(Strings.debit)),
//                 DataColumn(label: Text(Strings.credit)),
//                 DataColumn(label: Text(Strings.edit)),
//                 DataColumn(label: Text(Strings.delete)),
//               ],
//               rows: snapshot.docs.map((entry) {
//                 final transactionEntry = entry.data();
//                 number++;
//                 return DataRow(
//                   cells: [
//                     DataCell(ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 30),
//                         child: Text(number.toString()))),
//                     DataCell(Text(
//                       Jalali.fromDateTime(
//                           transactionEntry['gregorian_date'].toDate())
//                           .formatCompactDate()
//                           .toString(),
//                     )),
//                     DataCell(Text(
//                       intl.DateFormat('yyyy-MM-dd')
//                           .format(transactionEntry['gregorian_date'].toDate()),
//                     )),
//                     DataCell(Text(transactionEntry['description'] ?? '')),
//                     DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
//                         transactionEntry['debit']))),
//                     DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
//                         transactionEntry['credit']))),
//                     DataCell(
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Directionality(
//                                 textDirection: TextDirection.rtl,
//                                 child: AlertDialog(
//                                   title: const Text(Strings.editTransaction),
//                                   content: AddTransaction(
//                                       transactionModel:
//                                       TransactionModel.fromMap(
//                                           transactionEntry, entry.id),
//                                       id: entry.id),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     DataCell(IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return ConfirmationDialog(
//                               title: Strings.dialogDeleteTitle +
//                                   transactionEntry['description'],
//                               message: Strings.dialogDeleteMessage,
//                               onConfirm: () async {
//                                 try {
//                                   await MoneyExchangeService.deleteTransaction(
//                                       entry.id);
//                                   Navigator.of(context).pop();
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Failed to delete transaction'),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                         );
//                       },
//                     )),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       );
//     } else {
//       return const Text(
//         Strings.transactionNotFound,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _pickDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       initialDateRange: _selectedDateRange ??
//           DateTimeRange(
//             start: DateTime.now().subtract(const Duration(days: 7)),
//             end: DateTime.now(),
//           ),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDateRange = picked;
//         _dateRangeController.text =
//         '${intl.DateFormat('yyyy-MM-dd').format(picked.start)} - ${intl.DateFormat('yyyy-MM-dd').format(picked.end)}';
//       });
//       _search();
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
//               return const Directionality(
//                 textDirection: TextDirection.rtl,
//                 child: AlertDialog(
//                   title: const Text(Strings.addTransaction),
//                   content: AddTransaction(),
//                 ),
//               );
//             },
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//       appBar: AppBar(
//         centerTitle: true,
//         title: LayoutBuilder(
//           builder: (context, constraints) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: constraints.maxWidth / 2,
//                   child: const Text(
//                     Strings.transactions,
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//                 const Expanded(
//                   child: Text(Strings.transactions, textAlign: TextAlign.right),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _transactionStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print(snapshot.error);
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return Directionality(
//             textDirection: TextDirection.rtl,
//             child: Column(
//               children: [
//                 const SizedBox(height: 18),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width > 600
//                       ? MediaQuery.of(context).size.width / 2
//                       : MediaQuery.of(context).size.width,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: Strings.searchByDescription,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             prefixIcon: IconButton(
//                               icon: const Icon(Icons.search),
//                               onPressed: () {
//                                 _search();
//                               },
//                             ),
//                             suffixIcon: IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 if (_searchController.text.isNotEmpty) {
//                                   _searchController.clear();
//                                   _search();
//                                 }
//                               },
//                             ),
//                           ),
//                           onSubmitted: (value) {
//                             _search();
//                           },
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.filter_list),
//                         onPressed: () {
//                           setState(() {
//                             _showFilters = !_showFilters;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_showFilters) const SizedBox(height: 10),
//                 if (_showFilters)
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width > 600
//                         ? MediaQuery.of(context).size.width / 2
//                         : MediaQuery.of(context).size.width,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: 200,
//                             child: TextField(
//                               controller: _dateRangeController,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 hintText: Strings.dateRange,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                               ),
//                               onTap: () async {
//                                 await _pickDateRange(context);
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           SizedBox(
//                             width: 200,
//                             child: TextField(
//                               controller: _specificDateController,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 hintText: Strings.date,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                               ),
//                               onTap: () async {
//                                 DateTime? picked = await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (picked != null) {
//                                   _specificDateController.text =
//                                       intl.DateFormat('yyyy-MM-dd')
//                                           .format(picked);
//                                   _search();
//                                 }
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: _isDebitChecked,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     _isDebitChecked = value!;
//                                   });
//                                 },
//                               ),
//                               const Text(Strings.debit),
//                             ],
//                           ),
//                           const SizedBox(width: 10),
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: _isCreditChecked,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     _isCreditChecked = value!;
//                                   });
//                                 },
//                               ),
//                               const Text(Strings.credit),
//                             ],
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: _search,
//                             child: const Text(Strings.search),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: _clearFilters,
//                             child: const Text(Strings.clear),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Scrollbar(
//                       controller: _verticalScrollController,
//                       thumbVisibility: true,
//                       trackVisibility: true,
//                       child: SingleChildScrollView(
//                         controller: _verticalScrollController,
//                         scrollDirection: Axis.vertical,
//                         child: Scrollbar(
//                           controller: _horizontalScrollController,
//                           thumbVisibility: true,
//                           trackVisibility: true,
//                           child: SingleChildScrollView(
//                             controller: _horizontalScrollController,
//                             scrollDirection: Axis.horizontal,
//                             child: _buildDataTable(snapshot.data!),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Visibility(
//                         visible: _currentPage > 1,
//                         child: TextButton(
//                           onPressed: _handlePreviousPage,
//                           child: const Text(Strings.previous),
//                         ),
//                       ),
//                       const SizedBox(width: 10.0),
//                       Text('${Strings.page} $_currentPage'),
//                       const SizedBox(width: 10.0),
//                       Visibility(
//                         visible: snapshot.data!.docs.length == _pageSize,
//                         child: TextButton(
//                           onPressed: _handleNextPage,
//                           child: const Text(Strings.next),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:math';

import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/money_exchange/add_transaction.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/utilities/date_time_utils.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:intl/intl.dart' as intl;

class MoneyExchange extends StatefulWidget {
  @override
  _MoneyExchangeState createState() => _MoneyExchangeState();
}

class _MoneyExchangeState extends State<MoneyExchange> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateRangeController = TextEditingController();
  final TextEditingController _specificDateController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _showFilters = false;
  bool _isDebitChecked = false;
  bool _isCreditChecked = false;
  int _currentPage = 1;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _transactionStream;
  late DocumentSnapshot lastRecordedDocumentId;
  // DateTimeRange? _selectedDateRange;
   JalaliRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _transactionStream = _getTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateRangeController.dispose();
    _specificDateController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getTransactions({
    bool isSearching = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('money_exchange');

    // Apply search filter if needed
    if (_searchController.text.isNotEmpty) {
      query = query
          .where('description', isGreaterThanOrEqualTo: _searchController.text)
          .where('description',
              isLessThanOrEqualTo: '${_searchController.text}\uf8ff');
    }

    // Apply date filtering (specific or range)
    if (_specificDateController.text.isNotEmpty) {
      Jalali jalaliDate =
          DateTimeUtils.stringToJalaliDate(_specificDateController.text);
      DateTime specificDate = jalaliDate.toDateTime();

      query = query.where('gregorian_date', isEqualTo: specificDate);
    } else if (_selectedDateRange != null) {
      query = query
          .where('gregorian_date', isGreaterThanOrEqualTo: _selectedDateRange!.start.toDateTime())
          .where('gregorian_date', isLessThanOrEqualTo: _selectedDateRange!.end.toDateTime());
    }

    // Filter by debit/credit if a checkbox is selected, unless both are checked
    if (!(_isDebitChecked && _isCreditChecked)) {
      if (_isDebitChecked) {
        query = query.where('debit', isGreaterThan: 0);
      } else if (_isCreditChecked) {
        query = query.where('credit', isGreaterThan: 0);
      }
    }

    // Now that filtering is complete, order by date (if needed)
    if (_specificDateController.text.isEmpty &&
        _selectedDateRange == null &&
        !(_isDebitChecked || _isCreditChecked)) {
      // Only order by date if no other filtering is applied
      query = query.orderBy('date', descending: true);
    }

    // Pagination logic (unchanged)
    if (_currentPage > 1) {
      query = query.startAfterDocument(lastRecordedDocumentId);
    }

    query = query.limit(isSearching ? 1 : _pageSize);

    return query.snapshots();
  }

  void _handleNextPage() {
    setState(() {
      _currentPage++;
      _transactionStream = _getTransactions();
    });
  }

  void _handlePreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _transactionStream = _getTransactions();
      });
    }
  }

  void _search() {
    _currentPage = 1;
    setState(() {
      _transactionStream = _getTransactions(isSearching: false);
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _dateRangeController.clear();
      _specificDateController.clear();
      _isDebitChecked = false;
      _isCreditChecked = false;
      _selectedDateRange = null;
      _currentPage = 1;
      _transactionStream = _getTransactions(isSearching: false);
    });
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number = (_currentPage - 1) * _pageSize;
    if (snapshot.docs.isNotEmpty) {
      lastRecordedDocumentId = snapshot.docs.last;
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
                width: 0.1,
                color: Colors.grey,
                style: BorderStyle.solid,
              ),
              headingTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).highlightColor),
              columns: const [
                DataColumn(label: Text(Strings.number)),
                DataColumn(label: Text(Strings.jalaliDate)),
                DataColumn(label: Text(Strings.gregorianDate)),
                DataColumn(label: Text(Strings.description)),
                DataColumn(label: Text(Strings.debit)),
                DataColumn(label: Text(Strings.credit)),
                DataColumn(label: Text(Strings.edit)),
                DataColumn(label: Text(Strings.delete)),
              ],
              rows: snapshot.docs.map((entry) {
                final transactionEntry = entry.data();
                number++;
                return DataRow(
                  cells: [
                    DataCell(ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 30),
                        child: Text(number.toString()))),
                    DataCell(Text(
                      Jalali.fromDateTime(
                              transactionEntry['gregorian_date'].toDate())
                          .formatCompactDate()
                          .toString(),
                    )),
                    DataCell(Text(
                      intl.DateFormat('yyyy-MM-dd')
                          .format(transactionEntry['gregorian_date'].toDate()),
                    )),
                    DataCell(Text(transactionEntry['description'] ?? '')),
                    DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
                        transactionEntry['debit']))),
                    DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
                        transactionEntry['credit']))),
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
                                  title: const Text(Strings.editTransaction),
                                  content: AddTransaction(
                                      transactionModel:
                                          TransactionModel.fromMap(
                                              transactionEntry, entry.id),
                                      id: entry.id),
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
                              title: Strings.dialogDeleteTitle +
                                  transactionEntry['description'],
                              message: Strings.dialogDeleteMessage,
                              onConfirm: () async {
                                try {
                                  await MoneyExchangeService.deleteTransaction(
                                      entry.id);
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Failed to delete transaction'),
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
      return const Text(
        Strings.transactionNotFound,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final JalaliRange? picker = await showDariDateRangePicker(
      context: context,
      firstDate: Jalali(Jalali.now().year, Jalali.now().month-1),
      lastDate: Jalali.now(),
    );

    if(picker != null){
      _selectedDateRange = picker;
      _dateRangeController.text = '${picker.start.formatCompactDate()} - ${picker.end.formatCompactDate()}';
      _specificDateController.clear();
    }
    _search();
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
                  title: const Text(Strings.addTransaction),
                  content: AddTransaction(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: StreamBuilder<double>(
          stream: MoneyExchangeService.getBalanceStream(),
          builder: (context, snapshot) {
            double balance = snapshot.hasData ? snapshot.data! : 0.0;
            return Row(
              children: [
                Expanded(
                    child: Text(
                  '${balance >= 0 ? '' : '- '}${Strings.balance}: ${GeneralFormatter.formatNumber(balance.abs().toString()).split('.')[0]}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: balance >= 0
                          ? Colors.green
                          : Colors.red), // Set text alignment to start
                )),
                const Expanded(
                  child: Text(Strings.transactions, textAlign: TextAlign.right),
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _transactionStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: Strings.searchByDescription,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                              if (!_showFilters) {
                                _clearFilters();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // if (_showFilters) const SizedBox(height: 10),
                if (_showFilters)
                  Container(
                    color: AppColors.appBarBG,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextFormField(
                            label: Strings.dateRange,
                            controller: _dateRangeController,
                            readOnly: true,
                            onTap: () async {
                              await _pickDateRange(context);
                            },
                            displaySuffix: false,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomTextFormField(
                            label: Strings.date,
                            displaySuffix: false,
                            controller: _specificDateController,
                            readOnly: true,
                            onTap: () async {
                              final Jalali? picked = await showDariDatePicker(
                                context: context,
                                initialDate: Jalali.now(),
                                firstDate: Jalali(1385, 8),
                                lastDate: Jalali(1450, 9),
                                initialEntryMode:
                                    DDatePickerEntryMode.calendarOnly,
                                initialDatePickerMode: DDatePickerMode.day,
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData(
                                      dialogTheme: const DialogTheme(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0)),
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                _dateRangeController.clear();
                                _specificDateController.text =
                                    picked.formatCompactDate();
                                _search();
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isDebitChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isDebitChecked = value!;
                                      });
                                    },
                                  ),
                                  const Text(Strings.debit),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isCreditChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isCreditChecked = value!;
                                      });
                                    },
                                  ),
                                  const Text(Strings.credit),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: _search,
                                icon: const Icon(Icons.search),
                              ),
                              IconButton(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
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
