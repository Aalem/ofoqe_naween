import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/money_exchange/models/exchange_model.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/add_exchange.dart';
import 'package:ofoqe_naween/pages/money_exchange/collection_fields/collection_fields.dart';
import 'package:ofoqe_naween/pages/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ExchangesPage extends StatefulWidget {
  const ExchangesPage({super.key});

  @override
  _ExchangesPageState createState() => _ExchangesPageState();
}

class _ExchangesPageState extends State<ExchangesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _exchangeStream;

  @override
  void initState() {
    super.initState();
    _exchangeStream = _getExchanges();
    _searchController.addListener(() {
      setState(() {
        _exchangeStream = _getExchanges();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getExchanges() {
    Query<Map<String, dynamic>> query = _firestore.collection(CollectionNames.exchanges);

    if (_searchController.text.isNotEmpty) {
      query = query
          .where(ExchangeFields.name, isGreaterThanOrEqualTo: _searchController.text)
          .where(ExchangeFields.name, isLessThanOrEqualTo: _searchController.text + '\uf8ff');
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.moneyExchanges),
      ),
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
      body: GenericDataTable<ExchangeModel>(
        columns: const [
          DataColumn(label: Text(Strings.number)), // Non-sortable
          DataColumn(label: Text(Strings.exchangeName)),
          DataColumn(label: Text(Strings.address)),
          DataColumn(label: Text(Strings.phoneNumbers)),
          DataColumn(label: Text(Strings.actions)), // Non-sortable
        ],
        dataStream: _exchangeStream!,
        fromMap: (data, id) => ExchangeModel.fromMap(data, id),
        deleteService: MoneyExchangeService.deleteExchange,
        addEditWidget: ({ExchangeModel? model, String? id}) => AddExchange(exchangeModel: model, id: id),
        cellBuilder: (ExchangeModel exchange) => [
          DataCell(Text(exchange.name ?? '')),
          DataCell(Text(exchange.address ?? '')),
          DataCell(
            Text(
              '${exchange.phoneNumber1 ?? ''}${exchange.phoneNumber2.isNotEmpty == true ? '\n${exchange.phoneNumber2}' : ''}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
        addTitle: Strings.addExchange,
        deleteTitlePrefix: Strings.deleteExchange,
        deleteMessage: Strings.deleteExchangeMessage,
        deleteSuccessMessage: Strings.exchangeDeletedSuccessfully,
        deleteFailureMessage: Strings.failedToDeletingTransaction,
        enableSearch: true,
        enableSort: true,
        searchFields: const [ExchangeFields.name],
        sortFields: [
              (ExchangeModel e) => e.name ?? '',
              (ExchangeModel e) => e.address ?? '',
              (ExchangeModel e) => e.phoneNumber1 ?? '',
        ],
      ),
    );
  }
}