import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/pages/products/models/brand.dart';
import 'package:ofoqe_naween/pages/products/services/brand_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddBrandPage extends StatefulWidget {
  final BrandModel? brand;
  final String? id;

  const AddBrandPage({super.key, this.brand, this.id});

  @override
  _AddBrandPageState createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late BrandModel _brand;

  @override
  void initState() {
    super.initState();
    _brand = widget.brand ?? BrandModel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                enabled: !_isLoading,
                label: Strings.brandName,
                controller: TextEditingController(text: _brand.name),
                validationMessage: Strings.enterBrandName,
                onSaved: (value) => _brand.name = value!,
              ),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _brand.description),
                label: Strings.description,
                onSaved: (value) => _brand.description = value!,
              ),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _brand.country),
                label: Strings.country,
                onSaved: (value) => _brand.country = value!,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: DialogButton(
                      buttonType: ButtonType.positive,
                      title: Strings.save,
                      onPressed: _isLoading ? null : _saveBrandToFirestore,
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
                              content: const Text(Strings.dialogCancelMessage),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // close dialog
                                    Navigator.pop(context); // close page
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

  Future<void> _saveBrandToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      Navigator.pop(context);

      if (widget.id != null) {
        await BrandService().updateDocument(widget.id!, _brand);
        NotificationService().showSuccess(Strings.brandUpdatedSuccessfully);
      } else {
        await BrandService().addDocument(_brand);
        NotificationService().showSuccess(Strings.brandAddedSuccessfully);
      }
    } catch (e) {
      NotificationService().showError(Strings.anErrorOccurred);
      setState(() => _isLoading = false);
    }
  }
}
