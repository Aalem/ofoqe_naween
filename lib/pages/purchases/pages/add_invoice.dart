import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/models/currency.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/pages/purchases/purchases.dart';
import 'package:ofoqe_naween/pages/suppliers/models/supplier_model.dart';
import 'package:ofoqe_naween/services/firebase/currency_service.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';

import '../../suppliers/services/supplier_service.dart';

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  _AddInvoicePageState createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _jalaliDateTextController =
      TextEditingController();
  final TextEditingController _gregorianDateTextController =
      TextEditingController();

  late Future<List<Currency>> _currenciesFuture;
  Currency? _selectedCurrency;

  List<Supplier> _suppliers = [];
  String? _selectedSupplierId;
  Jalali? _selectedDate;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _currenciesFuture = CurrencyService.getCurrencies();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final suppliers = await SupplierService.getSuppliers();
      setState(() {
        _suppliers = suppliers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suppliers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(Strings.addInvoice),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false)
                    .updatePage(PurchasesPage());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...ResponsiveHelper.genResponsiveWidgets([
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: Strings.supplier),
                    items: _suppliers.map((supplier) {
                      return DropdownMenuItem<String>(
                        value: supplier.name,
                        child: Text(supplier.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplierId = value;
                      });
                    },
                    value: _selectedSupplierId,
                  ),
                ),
                CustomTextFormField(
                  controller: _invoiceNumberController,
                  label: Strings.invoiceNumber,
                ),
                CustomTextFormField(
                  controller: _jalaliDateTextController,
                  label: Strings.jalaliDate,
                  readOnly: true,
                  validationMessage: Strings.selectADate,
                  onTap: () async {
                    final Jalali? picked = await showDariDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? Jalali.now(),
                      firstDate: Jalali(1385, 8),
                      lastDate: Jalali(1450, 9),
                      initialEntryMode: DDatePickerEntryMode.calendarOnly,
                      initialDatePickerMode: DDatePickerMode.day,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            dialogTheme: const DialogTheme(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0)),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _jalaliDateTextController.text =
                            _selectedDate!.formatCompactDate();
                        _gregorianDateTextController.text =
                            GeneralFormatter.formatDate(_selectedDate!
                                .toGregorian()
                                .toDateTime()
                                .toString());
                      });
                    }
                  },
                ),
                CustomTextFormField(
                  controller: _gregorianDateTextController,
                  label: Strings.gregorianDate,
                  readOnly: true,
                  validationMessage: Strings.selectADate,
                  onTap: () async {
                    DateTime initialGregorianDate =
                        _selectedDate?.toGregorian().toDateTime() ??
                            DateTime.now();
                    DateTime now = DateTime.now();
                    DateTime firstDate = DateTime(2020, 1, 1);
                    DateTime lastDate = now;

                    // Ensure the initial date is within the allowable range
                    if (initialGregorianDate.isAfter(lastDate)) {
                      initialGregorianDate = lastDate;
                    } else if (initialGregorianDate.isBefore(firstDate)) {
                      initialGregorianDate = firstDate;
                    }

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initialGregorianDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked.toJalali();
                        _jalaliDateTextController.text =
                            _selectedDate!.formatCompactDate();
                        _gregorianDateTextController.text =
                            GeneralFormatter.formatDate(_selectedDate!
                                .toGregorian()
                                .toDateTime()
                                .toString());
                      });
                    }
                  },
                ),
              ], context),
              buildCurrencyPicker(),
              InvoiceItemsTable()
            ],
          ),
        ),
      ),
    );
  }

  Row buildCurrencyPicker() {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<List<Currency>>(
            future: _currenciesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No currencies available.'));
              }

              final currencies = snapshot.data!;

              return DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                items: currencies.map((currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(
                      currency.name,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (Currency? newCurrency) {
                  setState(() {
                    _selectedCurrency = newCurrency;
                  });
                },
                icon: _selectedCurrency != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _selectedCurrency!.symbol,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : null,
                decoration: InputDecoration(
                  labelText: Strings.chooseCurrency,
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: CustomTextFormField(label: Strings.valueInUSD, enabled: _selectedCurrency?.symbol!='\$'),
        ),
        Expanded(
          flex: 4,
          child: CustomTextFormField(
            keyboardType: TextInputType.text,
            controller: _notesController,
            label: Strings.notes,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class CurrencyFields extends StatefulWidget {
  const CurrencyFields({super.key});

  @override
  State<CurrencyFields> createState() => _CurrencyFieldsState();
}

class _CurrencyFieldsState extends State<CurrencyFields> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class InvoiceItemsTable extends StatefulWidget {
  const InvoiceItemsTable({super.key});

  @override
  State<InvoiceItemsTable> createState() => _InvoiceItemsTableState();
}

class _InvoiceItemsTableState extends State<InvoiceItemsTable> {
  List<Map<String, dynamic>> _invoiceItems = [
    {
      'code': 'A001',
      'description': 'Laptop',
      'quantity': '2',
      'price': '1500',
      'discount': '5%',
      'unitPriceAfterDiscount': '1425',
      'totalPrice': '2850',
    },
    {
      'code': 'B002',
      'description': 'Mouse',
      'quantity': '3',
      'price': '20',
      'discount': '10%',
      'unitPriceAfterDiscount': '18',
      'totalPrice': '54',
    },
    {
      'code': 'C003',
      'description': 'Keyboard',
      'quantity': '1',
      'price': '50',
      'discount': '0%',
      'unitPriceAfterDiscount': '50',
      'totalPrice': '50',
    },
    {
      'code': 'D004',
      'description': 'Monitor',
      'quantity': '2',
      'price': '200',
      'discount': '15%',
      'unitPriceAfterDiscount': '170',
      'totalPrice': '340',
    },
    {
      'code': 'E005',
      'description': 'Desk Chair',
      'quantity': '1',
      'price': '100',
      'discount': '5%',
      'unitPriceAfterDiscount': '95',
      'totalPrice': '95',
    },
  ];

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  TextEditingController? productNameController;
  TextEditingController? productCodeController;
  TextEditingController? quantityController;
  TextEditingController? priceController;
  TextEditingController? discountController;

  int _rowsPerPage = 5;

  void _addInvoiceItem() {
    final code = _codeController.text.trim();
    final description = _descriptionController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;

    if (code.isNotEmpty &&
        description.isNotEmpty &&
        quantity > 0 &&
        unitPrice > 0) {
      final unitPriceAfterDiscount = unitPrice - (unitPrice * discount / 100);
      final totalPrice = unitPriceAfterDiscount * quantity;

      setState(() {
        _invoiceItems.add({
          'code': code,
          'description': description,
          'quantity': quantity,
          'discount': discount,
          'unitPriceAfterDiscount': unitPriceAfterDiscount,
          'totalPrice': totalPrice,
        });
      });

      _codeController.clear();
      _descriptionController.clear();
      _quantityController.clear();
      _discountController.clear();
      _unitPriceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields correctly.')),
      );
    }
  }

  List<Widget> addNewItemWidgets({
    required VoidCallback onSubmit,
  }) {
    return [
      Expanded(
        child: TextField(
          controller: productNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: TextField(
          controller: productCodeController,
          decoration: InputDecoration(
            labelText: 'Product Code',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: TextField(
          controller: discountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Discount (%)',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: ElevatedButton(
          onPressed: onSubmit,
          child: Text('Add Item'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_invoiceItems.isEmpty) {
      return NoDataExists();
    }

    _rowsPerPage = 10;
    _rowsPerPage = _invoiceItems.length < _rowsPerPage
        ? _invoiceItems.length
        : _rowsPerPage;

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: Theme.of(context).cardTheme.copyWith(
            elevation: 0, margin: EdgeInsets.zero, color: Colors.white),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: PaginatedDataTable(
            header: Column(
              children: [
                // Text('Hello'),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: Strings.addPurchaseItem,
                      labelStyle: TextStyle(
                          decorationStyle: TextDecorationStyle.dashed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      children: [...addNewItemWidgets(onSubmit: () {})],
                    ),
                  ),
                ),
              ],
            ),
            showEmptyRows: false,
            // hidePaginator: true,
            // wrapInCard: false,
            // actions: [Text('Hello')],
            rowsPerPage: _rowsPerPage,
            columns: const [
              DataColumn(
                label: Text(Strings.number),
                // size: ColumnSize.S,
              ),
              DataColumn(
                label: Text(Strings.code),
              ),
              DataColumn(
                label: Text(Strings.description),
              ),
              DataColumn(
                label: Text(Strings.quantity),
              ),
              DataColumn(
                label: Text(Strings.price),
              ),
              DataColumn(
                label: Text(Strings.discount),
              ),
              DataColumn(
                label: Text(Strings.unitPriceAfterDiscount),
              ),
              DataColumn(
                label: Text(Strings.totalPrice),
              ),
              DataColumn(
                label: Text(Strings.actions),
              ),
            ],
            source: TransactionDataSource(_invoiceItems, context),
          ),
        ),
      ),
    );
  }
}

class TransactionDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _items;

  final BuildContext context;
  int number = 0;

  TransactionDataSource(this._items, this.context);

  @override
  DataRow getRow(int index) {
    final item = _items[index];
    if (index >= _items.length) return DataRow(cells: []);

    number = index + 1;

    return DataRow(cells: [
      DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 30),
          child: Text(number.toString()))),
      DataCell(
        Text(item['code']),
      ),
      DataCell(Text(item['description'] ?? '')),
      DataCell(Text(item['quantity'] ?? '')),
      DataCell(Text(item['price'] ?? '')),
      DataCell(Text(item['discount'])),
      DataCell(Text(item['unitPriceAfterDiscount'])),
      DataCell(Text(item['totalPrice'])),
      DataCell(
        PopupMenuButton<int>(
          onSelected: (i) {
            switch (i) {
              case 1:
                // Navigator.pop(context); // Close the popup
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: const Text(Strings.editTransaction),
                //         content: AddTransaction(
                //             transactionModel: TransactionModel.fromMap(
                //                 transactionEntry, filteredDocs[index].id),
                //             id: filteredDocs[index].id),
                //       );
                //     },
                //   );
                break;
              case 2:
              // Navigator.pop(context); // Close the popup
              //   showDialog(
              //     context: context,
              //     builder: (BuildContext context) {
              //       return ConfirmationDialog(
              //         title: Strings.deleteTransaction +
              //             (transactionEntry[MoneyExchangeFields.description] ??
              //                 ''),
              //         message: Strings.deleteTransactionMessage,
              //         onConfirm: () async {
              //           try {
              //             await MoneyExchangeService.deleteTransaction(
              //                 filteredDocs[index].id);
              //             Navigator.of(context).pop();
              //           } catch (e) {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               const SnackBar(
              //                 content:
              //                 Text(Strings.failedToDeletingTransaction),
              //                 backgroundColor: Colors.red,
              //               ),
              //             );
              //           }
              //         },
              //       );
              //     },
              //   );
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
  int get rowCount => _items.length;

  @override
  int get selectedRowCount => 0;
}
