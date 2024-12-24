import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/pages/money_exchange/models/exchange_model.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/add_exchange.dart';
import 'package:ofoqe_naween/pages/money_exchange/collection_fields/collection_fields.dart';
import 'package:ofoqe_naween/pages/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ExchangesPage extends StatefulWidget {
  const ExchangesPage({super.key});

  @override
  _ExchangesPageState createState() => _ExchangesPageState();
}

class _ExchangesPageState extends State<ExchangesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 10;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  int _rowsPerPage = 13;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _exchangeStream;

  @override
  void initState() {
    super.initState();
    _exchangeStream = _getExchanges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getExchanges() {
    Query<Map<String, dynamic>> query =
        _firestore.collection(CollectionNames.exchanges);

    if (_searchController.text.isNotEmpty) {
      query = query
          .where(ExchangeFields.name,
              isGreaterThanOrEqualTo: _searchController.text)
          .where(ExchangeFields.name,
              isLessThanOrEqualTo: _searchController.text + '\uf8ff');
    }

    return query.snapshots();
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
                  DataColumn(label: Text(Strings.exchangeName)),
                  DataColumn(label: Text(Strings.address)),
                  DataColumn(label: Text(Strings.phoneNumbers)),
                  DataColumn(label: Text(Strings.actions)),
                ],
                source: _DataTableSource(
                  context: context,
                  exchanges: filteredDocs,
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(child: _buildPaginatedDataTable(snapshot.data!));
        },
      ),
    );
  }
}

class _DataTableSource extends DataTableSource {
  final BuildContext context;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> exchanges;
  final int numberOffset;

  _DataTableSource({
    required this.context,
    required this.exchanges,
    required this.numberOffset,
  });

  @override
  DataRow getRow(int index) {
    final exchangeEntry = exchanges[index].data();
    int number = numberOffset + index + 1;

    return DataRow(cells: [
      DataCell(Text(number.toString())),
      DataCell(Text(exchangeEntry[ExchangeFields.name] ?? '')),
      DataCell(Text(exchangeEntry[ExchangeFields.address] ?? '')),
      DataCell(
        Text(
          '${exchangeEntry[ExchangeFields.phone1] ?? ''} '
              '${exchangeEntry[ExchangeFields.phone2].isNotEmpty ? '\n${exchangeEntry[ExchangeFields.phone2]}' : ''}',
          textDirection: TextDirection.ltr,
        ),
      ),
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
                      content: AddExchange(
                          exchangeModel: ExchangeModel.fromFirestore(
                              exchangeEntry, exchanges[index].id),
                          id: exchanges[index].id),
                    );
                  },
                );
                break;
              case 2:
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      title: Strings.deleteExchange +
                          (exchangeEntry[ExchangeFields.name] ?? ''),
                      message: Strings.deleteExchangeMessage,
                      onConfirm: () async {
                        // Save the scaffold messenger context
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        // Close the dialog before performing async operation
                        Navigator.of(context).pop();

                        try {
                          // Attempt to delete the exchange
                          await MoneyExchangeService.deleteExchange(
                              exchanges[index].id);

                          // If successful, show a success message
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content:
                                  Text(Strings.exchangeDeletedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          // Handle any error (like related transactions) and show a SnackBar
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(e
                                      .toString()
                                      .contains('related to this exchange')
                                  ? Strings
                                      .failedToDeleteDueToRelatedTransactions
                                  : Strings.failedToDeletingTransaction),
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
  int get rowCount => exchanges.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
