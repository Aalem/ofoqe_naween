import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/values/strings.dart';

class NewCustomerPage extends StatefulWidget {
  final Map<String, dynamic>? customerData; // Customer data for editing

  const NewCustomerPage({Key? key, this.customerData}) : super(key: key);

  @override
  _NewCustomerPageState createState() => _NewCustomerPageState();
}

class _NewCustomerPageState extends State<NewCustomerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _name;
  late String _email;
  late String _phone1;
  late String _phone2;
  late String _address;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with customer data if provided
    if (widget.customerData != null) {
      _name = widget.customerData!['name'] ?? '';
      _email = widget.customerData!['email'] ?? '';
      _phone1 = widget.customerData!['phone1'] ?? '';
      _phone2 = widget.customerData!['phone2'] ?? '';
      _address = widget.customerData!['address'] ?? '';
    } else {
      // Initialize form fields with empty values if no customer data provided
      _name = '';
      _email = '';
      _phone1 = '';
      _phone2 = '';
      _address = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width / 2
          : null,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: Strings.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterName;
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: Strings.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterEmail;
                  } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                    return Strings.enterValidEmail;
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _phone1,
                decoration: const InputDecoration(labelText: Strings.phone1),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Add validation for phone number format (optional)
                  return null;
                },
                onSaved: (value) => _phone1 = value!,
              ),
              TextFormField(
                initialValue: _phone2,
                decoration: const InputDecoration(labelText: Strings.phone2),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Add validation for phone number format (optional)
                  return null;
                },
                onSaved: (value) => _phone2 = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: Strings.address),
                maxLines: null,
                // Allow multiple lines for address
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterAddress;
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _saveCustomerToFirestore();
                          }
                        },
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
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  title: const Text(Strings.dialogCancelTitle),
                                  content:
                                      const Text(Strings.dialogCancelMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(
                                            context); // Close the dialog and the page
                                      },
                                      child: const Text(Strings.yes),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(Strings.no),
                                    ),
                                  ],
                                ),
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

  Future<void> _saveCustomerToFirestore() async {
    try {
      final customerData = {
        'name': _name,
        'email': _email,
        'phone1': _phone1,
        'phone2': _phone2,
        'address': _address,
      };

      if (widget.customerData != null) {
        // Editing an existing customer
        final String customerId =
            widget.customerData!['id']; // Assuming 'id' is the document ID
        customerData['id'] = customerId; // Add the document ID to the data
        await _firestore
            .collection('customers')
            .doc(customerId)
            .update(customerData)
            .then((_) {
          NotificationService().showSuccess(
              context,
              widget.customerData != null
                  ? Strings.customerUpdatedSuccessfully
                  : Strings.customerAddedSuccessfully);
          Navigator.pop(context);
        });
      } else {
        // Adding a new customer
        await _firestore
            .collection('customers')
            .add(customerData)
            .then((value) {
          NotificationService()
              .showSuccess(context, Strings.customerAddedSuccessfully);
          Navigator.pop(context);
        });
      }
    } on FirebaseException catch (e) {
      NotificationService().showError(
          context,
          widget.customerData != null
              ? Strings.errorUpdatingCustomer
              : Strings.errorAddingCustomer);
    } catch (e) {
      NotificationService().showSuccess(context, Strings.anErrorOccurred);
    }
  }
}
