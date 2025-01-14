import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/pages/products/services/category_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:ofoqe_naween/pages/products/models/category.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryModel? category; // Product data for editing
  final String? id;

  const AddCategoryPage({super.key, this.category, this.id});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late CategoryModel _category;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _category = widget.category!;
    } else {
      _category = CategoryModel();
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
                  label: Strings.categoryName,
                  controller: TextEditingController(
                    text: _category.name,
                  ),
                  validationMessage: Strings.enterProductName,
                  onSaved: (value) => _category.name = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller:
                      TextEditingController(text: _category.description),
                  label: Strings.description,
                  onSaved: (value) => _category.description = value!,
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
                                // Implement save logic here
                                _saveProductToFirestore();
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

  Future<void> _saveProductToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      Navigator.pop(context);
      if (widget.id != null) {
        // Update existing product
        await CategoryService().updateDocument(widget.id!, _category);
        NotificationService().showSuccess(Strings.categoryUpdatedSuccessfully);
      } else {
        // Add new product
        await CategoryService().addDocument(_category);
        NotificationService().showSuccess(Strings.categoryAddedSuccessfully);
      }
    } catch (e) {
      NotificationService().showSuccess(Strings.anErrorOccurred);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
