import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/exchange_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/pages/add_exchange.dart';
import 'package:ofoqe_naween/screens/money_exchange/collection_fields/collection_fields.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class MoneyExchangesPage extends StatefulWidget {
  @override
  _MoneyExchangesPageState createState() => _MoneyExchangesPageState();
}

class _MoneyExchangesPageState extends State<MoneyExchangesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  int _currentPage = 1;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _exchangeStream;
  late DocumentSnapshot lastRecordedDocumentId;

  @override
  void initState() {
    super.initState();
    _exchangeStream = _getExchanges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getExchanges({
    bool isSearching = false,
  }) {
    Query<Map<String, dynamic>> query =
    _firestore.collection(CollectionNames.exchanges);

    // Filter by description if search query is provided
    if (_searchController.text.isNotEmpty) {
      query = query.where(ExchangeFields.name,
          isGreaterThanOrEqualTo: _searchController.text)
          .where(ExchangeFields.name,
          isLessThanOrEqualTo: _searchController.text + '\uf8ff');
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
      _exchangeStream = _getExchanges();
    });
  }

  void _handlePreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _exchangeStream = _getExchanges();
      });
    }
  }

  void _search() {
    _currentPage = 1;
    setState(() {
      _exchangeStream = _getExchanges(isSearching: false);
    });
  }

  void _clearFilters({bool keepDescription = false}) {
    setState(() {
      if (!keepDescription) _searchController.clear();
      _currentPage = 1;
      _exchangeStream = _getExchanges(isSearching: false);
    });
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number = (_currentPage - 1) * _pageSize;
    if (snapshot.docs.isNotEmpty) {
      lastRecordedDocumentId = snapshot.docs.last;
      var filteredDocs = snapshot.docs;

      if (filteredDocs.isNotEmpty) {
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
                headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Theme.of(context).highlightColor),
                columns: const [
                  DataColumn(label: Text(Strings.number)),
                  DataColumn(label: Text(Strings.exchangeName)),
                  DataColumn(label: Text(Strings.address)),
                  DataColumn(label: Text(Strings.phoneNumbers)),
                  DataColumn(label: Text(Strings.edit)),
                  DataColumn(label: Text(Strings.delete)),
                ],
                rows: filteredDocs.map((entry) {
                  final exchangeEntry = entry.data();
                  number++;
                  return DataRow(
                    cells: [
                      DataCell(ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 30),
                          child: Text(number.toString()))),
                      DataCell(Text(
                          exchangeEntry[ExchangeFields.name] ??
                              '')),
                      DataCell(Text(
                          exchangeEntry[ExchangeFields.address] ??
                              '')),
                      DataCell(Text(
                          textDirection: TextDirection.ltr,
                          '${exchangeEntry[ExchangeFields.phone1]}\n${exchangeEntry[ExchangeFields.phone2]}'.trim())),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(Strings.editExchange),
                                  content: AddExchange(
                                      exchangeModel:
                                      ExchangeModel.fromFirestore(
                                          exchangeEntry, entry.id),
                                      id: entry.id),
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
                                title: Strings.deleteExchange +
                                    exchangeEntry[
                                    MoneyExchangeFields.description],
                                message: Strings.deleteTransactionMessage,
                                onConfirm: () async {
                                  try {
                                    await MoneyExchangeService
                                        .deleteTransaction(entry.id);
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(Strings
                                            .failedToDeletingTransaction),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text(Strings.addExchange),
                content: AddExchange(),
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
            print(snapshot.error);
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: Strings.searchByExchangeName,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              _clearFilters(keepDescription: true);
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
                          _clearFilters(keepDescription: true);
                          _search();
                        },
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
          );
        },
      ),
    );
  }
}
