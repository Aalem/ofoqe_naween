import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/screens/money_exchange/add_transaction.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
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
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  int _currentPage = 1;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _transactionStream;
  late DocumentSnapshot lastRecordedDocumentId;

  @override
  void initState() {
    super.initState();
    _transactionStream = _getTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getTransactions(
      {bool isSearching = false}) {
    Query<Map<String, dynamic>> query = _firestore.collection('money_exchange');

    if (_searchController.text.isNotEmpty) {
      query = query
          .where('description', isGreaterThanOrEqualTo: _searchController.text)
          .where('description',
          isLessThanOrEqualTo: '${_searchController.text}\uf8ff');
    } else {
      query = query.orderBy('date', descending: true);
    }

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
                    DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(transactionEntry['debit']))),
                    DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(transactionEntry['credit']))),
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
                                  content: AddTransaction(
                                      transactionModel: TransactionModel.fromMap(transactionEntry, entry.id), id: entry.id),
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
                  title: Text(Strings.addTransactionTitle),
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
                Expanded(child: Text(
                  '${balance >= 0 ? '' : '- '}${Strings.balance}: ${GeneralFormatter.formatNumber(balance.abs().toString()).split('.')[0]}',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red),// Set text alignment to start
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
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
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
                const SizedBox(height: 10),
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
