import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/models/customer_model.dart';
import 'package:ofoqe_naween/screens/customers/services/customer_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/theme/constants.dart';
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
        date: '',
        phone1: '',
        phone2: '',
      );
    }
  }

  List<Widget> getResponsiveRow(List<Widget> widgets) {
    return MediaQuery.of(context).size.width > 600
        ? [
            Row(
              children: [
                Expanded(child: widgets.first),
                Expanded(child: widgets.last),
              ],
            )
          ]
        : widgets;
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
              ...getResponsiveRow([
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
                  label: Strings.name,
                  validationMessage: Strings.enterName,
                  onSaved: (value) => _customer.name = value!,
                ),
              ]),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _customer.address),
                label: Strings.address,
                validationMessage: Strings.enterAddress,
                onSaved: (value) => _customer.address = value!,
              ),
              ...getResponsiveRow([
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
              ]),
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
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    title:
                                        const Text(Strings.dialogCancelTitle),
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
                                  ),
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
