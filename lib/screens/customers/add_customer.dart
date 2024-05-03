import 'package:flutter/material.dart';
import 'package:ofoqe_naween/models/customer_model.dart';
import 'package:ofoqe_naween/services/customer_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/values/strings.dart';

class NewCustomerPage extends StatefulWidget {
  final Customer? customer; // Customer data for editing
  final String? id;

  const NewCustomerPage({Key? key, this.customer, this.id}) : super(key: key);

  @override
  _NewCustomerPageState createState() => _NewCustomerPageState();
}

class _NewCustomerPageState extends State<NewCustomerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Customer _customer;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _customer = widget.customer!;
    } else {
      _customer = Customer(
        name: '',
        address: '',
        company: '',
        email: '',
        date: '',
        phone1: '',
        phone2: '',
      );
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
                enabled: !_isLoading,
                initialValue: _customer.company,
                decoration:
                const InputDecoration(labelText: Strings.company),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterCompany;
                  }
                  return null;
                },
                onSaved: (value) => _customer.company = value!,
              ),
              TextFormField(
                enabled: !_isLoading,
                initialValue: _customer.name,
                decoration:
                const InputDecoration(labelText: Strings.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterName;
                  }
                  return null;
                },
                onSaved: (value) => _customer.name = value!,
              ),
              TextFormField(
                enabled: !_isLoading,
                initialValue: _customer.email,
                decoration:
                const InputDecoration(labelText: Strings.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                    return Strings.enterValidEmail;
                  }
                  return null;
                },
                onSaved: (value) => _customer.email = value!,
              ),
              TextFormField(
                enabled: !_isLoading,
                initialValue: _customer.phone1,
                decoration:
                const InputDecoration(labelText: Strings.phone1),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  return null;
                },
                onSaved: (value) => _customer.phone1 = value!,
              ),
              TextFormField(
                enabled: !_isLoading,
                initialValue: _customer.phone2,
                decoration:
                const InputDecoration(labelText: Strings.phone2),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  return null;
                },
                onSaved: (value) => _customer.phone2 = value!,
              ),
              TextFormField(
                enabled: !_isLoading,
                initialValue: _customer.address,
                decoration:
                const InputDecoration(labelText: Strings.address),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.enterAddress;
                  }
                  return null;
                },
                onSaved: (value) => _customer.address = value!,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _saveCustomerToFirestore();
                          }
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(Strings.save),
                            if (_isLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  title: const Text(
                                      Strings.dialogCancelTitle),
                                  content: const Text(
                                      Strings.dialogCancelMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(Strings.yes),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
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
      setState(() {
        _isLoading = true;
      });
      final customerData = _customer.toMap();
      if (widget.id != null) {
        await CustomerService.updateCustomer(widget.id!, customerData);
        NotificationService().showSuccess(
          context,
          Strings.customerUpdatedSuccessfully,
        );
      } else {
        await CustomerService.addCustomer(customerData);
        NotificationService()
            .showSuccess(context, Strings.customerAddedSuccessfully);
      }
      Navigator.pop(context);
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      NotificationService().showError(
        context,
        widget.id != null
            ? Strings.errorUpdatingCustomer
            : Strings.errorAddingCustomer,
      );
    } catch (e) {
      print(e.toString());
      NotificationService().showSuccess(context, Strings.anErrorOccurred);
    }
  }
}
