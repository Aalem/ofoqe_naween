import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/suppliers/models/supplier_model.dart';
import 'package:ofoqe_naween/screens/suppliers/services/supplier_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddSupplierPage extends StatefulWidget {
  final Supplier? supplier; // Customer data for editing
  final String? id;

  const AddSupplierPage({super.key, this.supplier, this.id});

  @override
  _AddSupplierPageState createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Supplier _supplier;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _supplier = widget.supplier!;
    } else {
      _supplier = Supplier(
        name: '',
        address: '',
        products: '',
        email: '',
        website: '',
        phone1: '',
        phone2: '',
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
              CustomTextFormField(
                enabled: !_isLoading,
                label: Strings.supplier,
                controller: TextEditingController(text: _supplier.name,),
                validationMessage: Strings.enterSupplier,
                onSaved: (value) => _supplier.name = value!,
              ),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _supplier.products),
                label: Strings.products,
                onSaved: (value) => _supplier.products = value!,
              ),
              ...ResponsiveHelper.genResponsiveTwoWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _supplier.phone1),
                  validationMessage: Strings.enterCorrectNumber,
                  label: Strings.phone1,
                  canBeEmpty: true,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _supplier.phone1 = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _supplier.phone2),
                  label: Strings.phone2,
                  canBeEmpty: true,
                  keyboardType: TextInputType.phone,
                  validationMessage: Strings.enterCorrectNumber,
                  onSaved: (value) => _supplier.phone2 = value!,
                ),
              ], context),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _supplier.address),
                label: Strings.address,
                validationMessage: Strings.enterAddress,
                onSaved: (value) => _supplier.address = value!,
              ),
              ...ResponsiveHelper.genResponsiveTwoWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _supplier.email),
                  label: Strings.email,
                  keyboardType: TextInputType.emailAddress,
                  validationMessage: Strings.enterValidEmail,
                  onSaved: (value) => _supplier.email = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _supplier.website),
                  label: Strings.website,
                  keyboardType: TextInputType.url,
                  canBeEmpty: true,
                  validationMessage: Strings.enterValidWebsite,
                  onSaved: (value) => _supplier.website = value!,
                ),
              ], context),


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
                                await _saveSupplierToFirestore();
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

  Future<void> _saveSupplierToFirestore() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final supplierData = _supplier.toMap();
      if (widget.id != null) {
        await SupplierService.updateSupplier(widget.id!, supplierData);
        NotificationService().showSuccess(
          context,
          Strings.supplierUpdatedSuccessfully,
        );
      } else {
        await SupplierService.addSupplier(supplierData);
        NotificationService()
            .showSuccess(context, Strings.supplierAddedSuccessfully);
      }
      Navigator.pop(context);
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      NotificationService().showError(
        context,
        widget.id != null
            ? Strings.errorUpdatingSupplier
            : Strings.errorAddingSupplier,
      );
    } catch (e) {
      print(e.toString());
      NotificationService().showSuccess(context, Strings.anErrorOccurred);
    }
  }
}
