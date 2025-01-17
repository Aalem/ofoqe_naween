import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/pages/customers/models/customer_model.dart';
import 'package:ofoqe_naween/pages/customers/services/customer_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/values/constants.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';

class NewCustomerPage extends StatefulWidget {
  final Customer? customer; // Customer data for editing
  final String? id;

  const NewCustomerPage({super.key, this.customer, this.id});

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
        phone1: '',
        phone2: '',
        id: '',
        createdBy: '',
        updatedBy: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width / 1,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.company,
                  controller: TextEditingController(text: _customer.company),
                  validationMessage: Strings.enterCompany,
                  onSaved: (value) => _customer.company = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _customer.name),
                  label: Strings.customerName,
                  validationMessage: Strings.enterName,
                  onSaved: (value) => _customer.name = value!,
                ),
              ], context),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _customer.address),
                label: Strings.address,
                validationMessage: Strings.enterAddress,
                onSaved: (value) => _customer.address = value!,
              ),
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _customer.phone1),
                  validationMessage: Strings.enterCorrectNumber,
                  label: Strings.phone1,
                  canBeEmpty: true,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _customer.phone1 = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _customer.phone2),
                  label: Strings.phone2,
                  canBeEmpty: true,
                  keyboardType: TextInputType.phone,
                  validationMessage: Strings.enterCorrectNumber,
                  onSaved: (value) => _customer.phone2 = value!,
                ),
              ], context),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _customer.email),
                label: Strings.email,
                keyboardType: TextInputType.emailAddress,
                validationMessage: Strings.enterValidEmail,
                onSaved: (value) => _customer.email = value!,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: DialogButton(
                      buttonType: ButtonType.positive,
                      title: Strings.save,
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                await _saveCustomerToFirestore();
                              }
                            },
                    ),
                  ),
                  Expanded(
                      child: DialogButton(
                    title: Strings.cancel,
                    buttonType: ButtonType.negative,
                    onPressed: _isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(Strings.dialogCancelTitle),
                                  content:
                                      const Text(Strings.dialogCancelMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
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
                  )),
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
      Navigator.pop(context);
      if (widget.id != null) {
        await CustomerService().updateDocument(widget.id!, _customer);
        NotificationService().showSuccess(
          Strings.customerUpdatedSuccessfully,
        );
      } else {
        await CustomerService().addDocument(_customer);
        NotificationService()
            .showSuccess(Strings.customerAddedSuccessfully);
      }
    } on Exception catch (e) {
      print('$e');
      setState(() {
        _isLoading = false;
      });
      NotificationService().showError(
        widget.id != null
            ? Strings.errorUpdatingCustomer
            : Strings.errorAddingCustomer,
      );
    } catch (e) {
      print(e.toString());
      NotificationService().showSuccess( Strings.anErrorOccurred);
    }
  }
}
