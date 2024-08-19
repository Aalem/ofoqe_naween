import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/buttons/button_icon.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/money_exchange/pages/add_transaction.dart';
import 'package:ofoqe_naween/screens/money_exchange/collection_fields/collection_fields.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:ofoqe_naween/utilities/date_time_utils.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/utilities/screen_size.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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
    Query<Map<String, dynamic>> query =
    _firestore.collection(CollectionNames.moneyExchange);

    // Apply date filtering (specific or range)
    if (_specificDateController.text.isNotEmpty) {
      Jalali jalaliDate =
      DateTimeUtils.stringToJalaliDate(_specificDateController.text);
      DateTime specificDate = jalaliDate.toDateTime();

      query = query.where(MoneyExchangeFields.gregorianDate,
          isEqualTo: specificDate);
    } else if (_selectedDateRange != null) {
      query = query
          .where(MoneyExchangeFields.gregorianDate,
          isGreaterThanOrEqualTo: _selectedDateRange!.start.toDateTime())
          .where(MoneyExchangeFields.gregorianDate,
          isLessThanOrEqualTo: _selectedDateRange!.end.toDateTime());
    }

    // Filter by debit/credit if a checkbox is selected, unless both are checked
    if (!(_isDebitChecked && _isCreditChecked)) {
      if (_isDebitChecked) {
        query = query.where(MoneyExchangeFields.debit, isGreaterThan: 0);
      } else if (_isCreditChecked) {
        query = query.where(MoneyExchangeFields.credit, isGreaterThan: 0);
      }
    }

    // Now that filtering is complete, order by date (if needed)
    if (_specificDateController.text.isEmpty &&
        _selectedDateRange == null &&
        !(_isDebitChecked || _isCreditChecked)) {
      // Only order by date if no other filtering is applied
      // query = query.orderBy('date', descending: true);
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

  void _clearFilters({bool keepDescription = false}) {
    setState(() {
      if (!keepDescription) _searchController.clear();
      _dateRangeController.clear();
      _specificDateController.clear();
      _isDebitChecked = false;
      _isCreditChecked = false;
      _selectedDateRange = null;
      _currentPage = 1;
      _transactionStream = _getTransactions(isSearching: false);
    });
  }

  Future<Map<String, String>> _fetchExchangeNames(List<String> exchangeIds) async {
    Map<String, String> exchangeNames = {};
    if (exchangeIds.isEmpty) return exchangeNames;

    final exchangeCollection = _firestore.collection(CollectionNames.exchanges);
    final exchangeDocs = await exchangeCollection
        .where(FieldPath.documentId, whereIn: exchangeIds)
        .get();

    for (var doc in exchangeDocs.docs) {
      exchangeNames[doc.id] = doc.data()[ExchangeFields.name] ?? '';
    }

    return exchangeNames;
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    int number = (_currentPage - 1) * _pageSize;
    if (snapshot.docs.isNotEmpty) {
      lastRecordedDocumentId = snapshot.docs.last;

      var filteredDocs = snapshot.docs;
      if ((_isDebitChecked || _isCreditChecked) && _selectedDateRange != null) {
        filteredDocs = snapshot.docs.where((doc) {
          return doc.data()[MoneyExchangeFields.debit] > 0;
        }).toList();
      }
      if (_searchController.text.isNotEmpty) {
        filteredDocs = snapshot.docs.where((doc) {
          return doc
              .data()[MoneyExchangeFields.description]
              .contains(_searchController.text);
        }).toList();
      }
      if (_specificDateController.text.isEmpty &&
          _selectedDateRange == null &&
          !(_isDebitChecked || _isCreditChecked)) {
        filteredDocs.sort((a, b) =>
            b[MoneyExchangeFields.date].compareTo(a[MoneyExchangeFields.date]));
      }

      if (filteredDocs.isNotEmpty) {
        // Collect exchange IDs from transactions
        List<String> exchangeIds = filteredDocs
            .map((doc) => doc.data()[MoneyExchangeFields.exchangeId])
            .where((id) => id != null)
            .cast<String>()
            .toList();

        // Fetch exchange names asynchronously
        return FutureBuilder<Map<String, String>>(
          future: _fetchExchangeNames(exchangeIds),
          builder: (context, exchangeSnapshot) {
            if (exchangeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (exchangeSnapshot.hasError) {
              return Center(child: Text('Error: ${exchangeSnapshot.error}'));
            }

            Map<String, String> exchangeNames = exchangeSnapshot.data ?? {};

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
                      DataColumn(label: Text(Strings.jalaliDate)),
                      DataColumn(label: Text(Strings.gregorianDate)),
                      DataColumn(label: Text(Strings.moneyExchange)),
                      DataColumn(label: Text(Strings.description)),
                      DataColumn(label: Text(Strings.debit)),
                      DataColumn(label: Text(Strings.credit)),
                      DataColumn(label: Text(Strings.edit)),
                      DataColumn(label: Text(Strings.delete)),
                    ],
                    rows: filteredDocs.map((entry) {
                      final transactionEntry = entry.data();
                      number++;
                      String exchangeName = exchangeNames[transactionEntry[MoneyExchangeFields.exchangeId]] ?? '-';

                      return DataRow(
                        cells: [
                          DataCell(ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 30),
                              child: Text(number.toString()))),
                          DataCell(Text(
                            Jalali.fromDateTime(transactionEntry[
                            MoneyExchangeFields.gregorianDate]
                                .toDate())
                                .formatCompactDate()
                                .toString(),
                          )),
                          DataCell(Text(
                            GeneralFormatter.formatDate(
                                transactionEntry[MoneyExchangeFields.gregorianDate]
                                    .toDate()),
                          )),
                          DataCell(Text(exchangeName)),
                          DataCell(Text(
                              transactionEntry[MoneyExchangeFields.description] ??
                                  '')),
                          DataCell(Text(
                              GeneralFormatter.formatAndRemoveTrailingZeros(
                                  transactionEntry[MoneyExchangeFields.debit]))),
                          DataCell(Text(
                              GeneralFormatter.formatAndRemoveTrailingZeros(
                                  transactionEntry[MoneyExchangeFields.credit]))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(Strings.editTransaction),
                                      content: AddTransaction(
                                          transactionModel:
                                          TransactionModel.fromMap(
                                              transactionEntry, entry.id),
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
                                    title: Strings.deleteTransaction +
                                        transactionEntry[
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
          },
        );
      } else {
        return NothingFound();
      }
    } else {
      return NoDataExists();
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    Jalali currentDate = Jalali.now();
    final JalaliRange? picker = await showDariDateRangePicker(
      context: context,
      initialDateRange: JalaliRange(
        start: Jalali.fromDateTime(
            DateTime.now().subtract(const Duration(days: 4))),
        end: currentDate,
      ),
      firstDate: Jalali(currentDate.year - 10),
      lastDate: currentDate,
    );

    if (picker != null) {
      _selectedDateRange = picker;
      _dateRangeController.text =
      '${picker.start.formatCompactDate()} - ${picker.end.formatCompactDate()}';
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
              return AlertDialog(
                title: Text(Strings.addTransaction),
                content: AddTransaction(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
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
                          hintText: Strings.searchByDescription,
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
                    ButtonIcon(
                        icon: Icons.filter_list,
                        onPressed: () {
                          setState(() {
                            if (ScreenSize.isPhone(context)) {
                              showDialog(
                                  builder: (context) {
                                    return _buildFilterDialog(context);
                                  },
                                  context: context);
                            } else {
                              _showFilters = !_showFilters;
                              if (!_showFilters) {
                                _clearFilters();
                              }
                            }
                          });
                        }),
                  ],
                ),
              ),
              // if (_showFilters) const SizedBox(height: 10),
              if (_showFilters && ScreenSize.getWidth(context) >= 1200)
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
          );
        },
      ),
    );
  }

  Widget _buildFilterDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(Strings.filter),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  label: Strings.date,
                  controller: _specificDateController,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    var pickedDate = await showDariDatePicker(
                      context: context,
                      initialDate: Jalali.now(),
                      firstDate: Jalali(1385, 8),
                      lastDate: Jalali.now(),
                    );
                    if (pickedDate != null) {
                      _specificDateController.text =
                          pickedDate.formatCompactDate();
                    }
                  },
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: Strings.dateRange,
                  controller: _dateRangeController,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    var pickedDateRange = await showDariDateRangePicker(
                      context: context,
                      initialDateRange: JalaliRange(
                        start: Jalali.now().withDay(1),
                        end: Jalali.now(),
                      ),
                      firstDate: Jalali(1385, 8),
                      lastDate: Jalali.now(),
                    );
                    if (pickedDateRange != null) {
                      _selectedDateRange = pickedDateRange;
                      _dateRangeController.text =
                      "${pickedDateRange.start.formatCompactDate()} - ${pickedDateRange.end.formatCompactDate()}";
                    }
                  },
                ),
                const SizedBox(height: 10),
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
                    const SizedBox(width: 10),
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
          actions: [
            DialogButton(
              title: Strings.filter,
              buttonType: ButtonType.positive,
              onPressed: () {
                _search();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                _clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text(Strings.clearFilter),
            ),
          ],
        );
      },
    );
  }
}
