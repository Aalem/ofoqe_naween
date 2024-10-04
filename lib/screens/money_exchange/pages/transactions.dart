import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:ofoqe_naween/components/buttons/button_icon.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/components/texts/date_with_suffix.dart';
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
  final int _pageSize = 15;
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

  int _rowsPerPage = 12;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late TransactionDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _transactionStream = _getTransactions();
    _dataSource =
        TransactionDataSource([], 0, context); // Initialize with empty list
  }

  // Sorting handler
  void _sort<T>(
      Comparable<T> Function(DocumentSnapshot<Map<String, dynamic>>) getField,
      int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _dataSource.sort(getField, ascending);
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

    // Apply debit/credit filters
    if (_isDebitChecked || _isCreditChecked) {
      if (_isDebitChecked) {
        query = query.where(MoneyExchangeFields.debit, isGreaterThan: 0);
      }
      if (_isCreditChecked) {
        query = query.where(MoneyExchangeFields.credit, isGreaterThan: 0);
      }
    }

    // Pagination logic
    if (_currentPage > 1) {
      query = query.startAfterDocument(lastRecordedDocumentId);
    }

    query = query.limit(isSearching ? 1 : _pageSize);

    return query.snapshots();
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
      _transactionStream = _getTransactions(isSearching: false);
    });
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docs.isEmpty) {
      return NoDataExists();
    }

    lastRecordedDocumentId = snapshot.docs.last;
    var filteredDocs = snapshot.docs;

    // Apply debit/credit filters
    if (_isDebitChecked || _isCreditChecked) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data();
        final isDebit =
            _isDebitChecked && (data[MoneyExchangeFields.debit] ?? 0) > 0;
        final isCredit =
            _isCreditChecked && (data[MoneyExchangeFields.credit] ?? 0) > 0;
        return isDebit || isCredit;
      }).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        return (doc.data()[MoneyExchangeFields.description] ?? '')
            .contains(_searchController.text);
      }).toList();
    }
    _dataSource = TransactionDataSource(filteredDocs, 0, context);

    print('$_sortColumnIndex');
    // Apply sorting
    // _dataSource.sort(
    //   (doc) =>
    //       doc.data()?[MoneyExchangeFields.gregorianDate]?.toDate() ??
    //       DateTime.now(),
    //   _sortAscending,
    // );
    // Apply sorting before creating the data source
    if (filteredDocs.isNotEmpty) {
      filteredDocs.sort((a, b) {
        Comparable aValue;
        Comparable bValue;

        switch (_sortColumnIndex) {
          case 1: // No (this case can be omitted if not applicable)
            // This case can be omitted or modified based on your logic
            aValue = a.data()?[MoneyExchangeFields.gregorianDate]?.toDate() ??
                DateTime.now();
            bValue = b.data()?[MoneyExchangeFields.gregorianDate]?.toDate() ??
                DateTime.now();
            break;
          case 2: // Gregorian Date
            aValue = a.data()?[MoneyExchangeFields.gregorianDate]?.toDate() ??
                DateTime.now();
            bValue = b.data()?[MoneyExchangeFields.gregorianDate]?.toDate() ??
                DateTime.now();
            break;
          case 3: // Exchange Name
            aValue = a.data()?[MoneyExchangeFields.exchangeName] ?? '';
            bValue = b.data()?[MoneyExchangeFields.exchangeName] ?? '';
            break;
          case 4: // Description
            aValue = a.data()?[MoneyExchangeFields.description] ?? '';
            bValue = b.data()?[MoneyExchangeFields.description] ?? '';
            break;
          case 5: // Debit
            aValue = a.data()?[MoneyExchangeFields.debit] ?? 0;
            bValue = b.data()?[MoneyExchangeFields.debit] ?? 0;
            break;
          case 6: // Credit
            aValue = a.data()?[MoneyExchangeFields.credit] ?? 0;
            bValue = b.data()?[MoneyExchangeFields.credit] ?? 0;
            break;
          default:
            aValue = '';
            bValue = '';
        }

        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    }

    if (filteredDocs.isEmpty) {
      return NothingFound();
    }

    _rowsPerPage = 12;
    _rowsPerPage = _dataSource.rowCount < _rowsPerPage
        ? _dataSource.rowCount
        : _rowsPerPage;

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: Theme.of(context).cardTheme.copyWith(
            elevation: 0, margin: EdgeInsets.zero, color: Colors.white),
      ),
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          // header: Text('Hello'),
          showEmptyRows: false,
          // hidePaginator: true,
          // wrapInCard: false,
          // actions: [Text('Hello')],
          rowsPerPage: _rowsPerPage,
          // availableRowsPerPage: [_rowsPerPage, 20, 25, 30, 35],
          // onRowsPerPageChanged: (value) {
          //   setState(() {
          //     _rowsPerPage = value!;
          //   });
          // },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            const DataColumn(
              label: Text(Strings.number),
              // size: ColumnSize.S,
            ),
            DataColumn(
              label: const Text(Strings.date),
              onSort: (columnIndex, ascending) {
                _sort<DateTime>(
                    (doc) => doc
                        .data()?[MoneyExchangeFields.gregorianDate]
                        ?.toDate(),
                    columnIndex,
                    ascending);
              },
            ),
            const DataColumn(
              label: const Text(Strings.description),
            ),
            DataColumn(
              label: const Text(Strings.moneyExchange),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                    (doc) =>
                        doc.data()?[MoneyExchangeFields.exchangeName] ?? '',
                    columnIndex,
                    ascending);
              },
            ),
            DataColumn(
              label: const Text(Strings.debit),
              onSort: (columnIndex, ascending) {
                _sort<num>((doc) => doc.data()?[MoneyExchangeFields.debit] ?? 0,
                    columnIndex, ascending);
              },
            ),
            DataColumn(
              label: const Text(Strings.credit),
              onSort: (columnIndex, ascending) {
                _sort<num>(
                    (doc) => doc.data()?[MoneyExchangeFields.credit] ?? 0,
                    columnIndex,
                    ascending);
              },
            ),
            // Single Actions column
            const DataColumn(
              label: Text(Strings.actions),
            ),
          ],
          source: _dataSource,
          // onPageChanged: (index) {
          //   setState(() {
          //     _currentPage = index ~/ 10 + 1;
          //     _transactionStream = _getTransactions();
          //   });
          // },
        ),
      ),
    );
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

          // return _buildDataTable(snapshot.data!);

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                buildFilterByDescription(context),
                if (_showFilters && ScreenSize.getWidth(context) >= 1200)
                  buildAdditionalFilters(context),
                _buildDataTable(snapshot.data!),
              ],
            ),
          );
        },
      ),
    );
  }

  Container buildAdditionalFilters(BuildContext context) {
    return Container(
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
                  initialEntryMode: DDatePickerEntryMode.calendarOnly,
                  initialDatePickerMode: DDatePickerMode.day,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData(
                        dialogTheme: const DialogTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  _dateRangeController.clear();
                  _specificDateController.text = picked.formatCompactDate();
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
                          // _search();
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
                          // _search();
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
    );
  }

  Container buildFilterByDescription(BuildContext context) {
    return Container(
      color: AppColors.appBarBG,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
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

class TransactionDataSource extends DataTableSource {
  List<DocumentSnapshot<Map<String, dynamic>>> filteredDocs;
  final BuildContext context;
  int number;

  TransactionDataSource(this.filteredDocs, this.number, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= filteredDocs.length) return DataRow(cells: []);

    final transactionEntry = filteredDocs[index].data();
    number = index + 1;

    return DataRow(cells: [
      DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 30),
          child: Text(number.toString()))),
      DataCell(
        Column(
          children: [
            DateWithSuffix(
                date: Jalali.fromDateTime(
                        transactionEntry![MoneyExchangeFields.gregorianDate]
                            .toDate())
                    .formatCompactDate(),
                suffix: Strings.hijriDateSuffix),
            DateWithSuffix(
              date: GeneralFormatter.formatDate(
                  transactionEntry[MoneyExchangeFields.gregorianDate].toDate()),
              suffix: Strings.gregorianDateSuffix,
              dateColor: Colors.grey,
            ),
          ],
        ),
      ),
      DataCell(Text(transactionEntry[MoneyExchangeFields.description] ?? '')),
      DataCell(Text(transactionEntry[MoneyExchangeFields.exchangeName] ?? '')),
      DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
          transactionEntry[MoneyExchangeFields.debit]))),
      DataCell(Text(GeneralFormatter.formatAndRemoveTrailingZeros(
          transactionEntry[MoneyExchangeFields.credit]))),
      DataCell(
        PopupMenuButton<int>(
          onSelected: (i) {
            switch (i) {
              case 1:
                // Navigator.pop(context); // Close the popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(Strings.editTransaction),
                      content: AddTransaction(
                          transactionModel: TransactionModel.fromMap(
                              transactionEntry, filteredDocs[index].id),
                          id: filteredDocs[index].id),
                    );
                  },
                );
                break;
              case 2:
                // Navigator.pop(context); // Close the popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      title: Strings.deleteTransaction +
                          (transactionEntry[MoneyExchangeFields.description] ??
                              ''),
                      message: Strings.deleteTransactionMessage,
                      onConfirm: () async {
                        try {
                          await MoneyExchangeService.deleteTransaction(
                              filteredDocs[index].id);
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text(Strings.failedToDeletingTransaction),
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
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => filteredDocs.length;

  @override
  int get selectedRowCount => 0;

  // Sort method to apply sorting on the data source
  void sort<T>(
      Comparable<T> Function(DocumentSnapshot<Map<String, dynamic>> doc)
          getField,
      bool ascending) {
    filteredDocs.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
