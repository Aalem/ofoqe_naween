import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ofoqe_naween/values/strings.dart';

import '../../values/data.dart';

class AddLedgerEntry extends StatefulWidget {
  @override
  _AddLedgerEntryState createState() => _AddLedgerEntryState();
}

class _AddLedgerEntryState extends State<AddLedgerEntry> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  DateTime _selectedDate = DateTime.now(); // Stores selected date
  String _description = ''; // Stores entered description
  double _amount = 0.0; // Stores entered amount
  String _category = 'فروشات'; // Stores selected category (optional)
  String _account = 'مشتری ۱'; // Stores selected account (optional)
  String _paymentMethod = 'نقد'; // Stores selected payment method (optional)
  String _reference = ''; // Stores entered reference (optional)

  TextEditingController _dateTextController = TextEditingController();

  Future<void> _addLedgerEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final ledgerRef = FirebaseFirestore.instance.collection('ledger');

      await ledgerRef.add({
        'date': _selectedDate,
        'description': _description,
        'amount': _amount,
        'category': _category,
        'account': _account,
        'payment_method': _paymentMethod,
        'reference': _reference,
      });

      Navigator.pop(context); // Close the page after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width>600? MediaQuery.of(context).size.width/2: null,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _dateTextController,
                decoration: const InputDecoration(labelText: Strings.gregorianDate),
                readOnly: true,
                // Use date picker instead of direct input
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                      _dateTextController.text = intl.DateFormat.yMd()
                          .format(_selectedDate); // Format and set the date
                    });
                  }
                },
                validator: (value) =>
                value == null ? Strings.selectADate : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: Strings.description),
                validator: (value) =>
                value!.isEmpty ? Strings.enterDescription : null,
                onSaved: (newValue) => _description = newValue!,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: Strings.amount),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? Strings.enterAmount : null,
                onSaved: (newValue) => _amount = double.parse(newValue!),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _category,
                hint: const Text(Strings.selectCategory),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue as String;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _account,
                hint: const Text(Strings.selectAcount),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account,
                    child: Text(account),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _account = newValue as String;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _paymentMethod,
                hint: const Text(Strings.selectPaymentMethod),
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paymentMethod = newValue as String;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: Strings.reference),
                onSaved: (newValue) => _reference = newValue!,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _addLedgerEntry,
                        child: const Text(Strings.save),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(

                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey, // Change button color
                          // onSurface: Colors.white, // Change text color
                          textStyle: const TextStyle(color: Colors.white),
                          // Add more customization as needed
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(Strings.dialogCancelTitle),
                                content: const Text(Strings.dialogCancelMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context); // Close the dialog and the page
                                    },
                                    child: const Text(Strings.yes),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(Strings.no),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(Strings.cancel),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
