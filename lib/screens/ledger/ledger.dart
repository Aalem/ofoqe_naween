import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/screens/ledger/add_to_ledger.dart';
import 'dart:ui' as dartUI;
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';

class LedgerPage extends StatefulWidget {
  @override
  _LedgerPageState createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _ledgerStream;

  @override
  void initState() {
    super.initState();
    _getLedgerEntries();
  }

  Future<void> _getLedgerEntries() async {
    final ledgerRef = FirebaseFirestore.instance.collection('ledger');
    _ledgerStream = ledgerRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Provider.of<NavigationProvider>(context, listen: false).updatePage(AddLedgerEntry());
          // Navigator.pushNamed(context, '/ledger');
          // widget.loadPage(AddLedgerEntry());
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(Strings.addLedgerTitle),
                content: AddLedgerEntry(), // Your AddLedgerEntry widget here
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () {}, child: Text(Strings.newCustomer)),
            Text(Strings.ledger),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ledgerStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              final ledgerEntries = snapshot.data!.docs;
              return Directionality(
                textDirection: dartUI.TextDirection.rtl,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Enable vertical scrolling
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // Enable horizontal scrolling
                      child: DataTable(
                        headingTextStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Theme.of(context).highlightColor),
                        columns: [
                          DataColumn(label: Text(Strings.date)),
                          DataColumn(label: Text(Strings.description)),
                          DataColumn(label: Text(Strings.amount)),
                          DataColumn(label: Text(Strings.category)),
                          DataColumn(label: Text(Strings.account)),
                          DataColumn(label: Text(Strings.paymentMethod)),
                        ],
                        rows: ledgerEntries.map((entry) {
                          final ledgerEntry = entry.data();
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                  formatDate(ledgerEntry['date'].toDate()))),
                              DataCell(Text(ledgerEntry['description'] ??
                                  'No description')),
                              DataCell(Text(
                                ledgerEntry['amount']?.toStringAsFixed(2) ??
                                    '0.00',
                                style: TextStyle(
                                  color: ledgerEntry['amount'] as double < 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              )),
                              DataCell(Text(ledgerEntry['category'] ?? '')),
                              DataCell(Text(ledgerEntry['account'] ?? '')),
                              DataCell(
                                  Text(ledgerEntry['paymentMethod'] ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    // Implement your date formatting logic here
    // Replace with your preferred date format
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
