import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/pages/products/models/category.dart';
import 'package:ofoqe_naween/pages/products/models/product.dart';
import 'package:ofoqe_naween/pages/products/services/category_service.dart';
import 'package:ofoqe_naween/pages/products/services/product_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddProductPage extends StatefulWidget {
  final Product? product; // Product data for editing
  final String? id;

  const AddProductPage({super.key, this.product, this.id});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CategoryModel? _selectedCategory;
  List<CategoryModel>? categories;
  late Product _product;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product!;
    } else {
      _product = Product();
    }
  }

  Widget buildCategorySelection() {
    return StreamBuilder<List<CategoryModel>>(
      stream: CategoryService().getDocumentsStream().map((snapshot) => snapshot
          .docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No categories available.'));
        }

        final categories = snapshot.data!;

        // Preselect the category if editing a product
        if (widget.product != null && _selectedCategory == null) {
          _selectedCategory = categories.firstWhere(
              (category) => category.id == widget.product?.categoryId);
        }

        return DropdownButtonFormField<CategoryModel>(
          value: _selectedCategory,
          items: categories.map((category) {
            return DropdownMenuItem<CategoryModel>(
              value: category,
              child: Text(
                category.name!,
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (CategoryModel? newCategory) {
            setState(() {
              _selectedCategory = newCategory;
            });
          },
          decoration: const InputDecoration(
            labelText: Strings.chooseCategory,
            border: OutlineInputBorder(),
          ),
        );
      },
    );
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
                  label: Strings.productName,
                  controller: TextEditingController(
                    text: _product.name,
                  ),
                  validationMessage: Strings.enterProductName,
                  onSaved: (value) => _product.name = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.code),
                  label: Strings.productCode,
                  onSaved: (value) => _product.code = value!,
                ),
                buildCategorySelection(),
              ], context),
              CustomTextFormField(
                enabled: !_isLoading,
                controller: TextEditingController(text: _product.description),
                label: Strings.description,
                onSaved: (value) => _product.description = value!,
                maxLines: 2,
              ),
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.brand),
                  label: Strings.productBrand,
                  onSaved: (value) => _product.brand = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.model),
                  label: Strings.productModel,
                  onSaved: (value) => _product.model = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.warranty),
                  label: Strings.productWarranty,
                  onSaved: (value) => _product.warranty = value!,
                ),
              ], context),
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.unit),
                  label: Strings.productUnit,
                  validationMessage: Strings.enterProductUnit,
                  onSaved: (value) => _product.unit = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.color),
                  label: Strings.productColor,
                  onSaved: (value) => _product.color = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(text: _product.dimension),
                  label: Strings.productDimension,
                  onSaved: (value) => _product.dimension = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  controller: TextEditingController(
                    text: _product.weight.toString(),
                  ),
                  label: Strings.productWeight,
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _product.weight = double.tryParse(value!) ?? 0.0,
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
      _product.categoryId = _selectedCategory!.id;
      Navigator.pop(context);
      if (widget.id != null) {
        // Update existing product
        await ProductService().updateDocument(widget.id!, _product);
        NotificationService().showSuccess(Strings.productUpdatedSuccessfully);
      } else {
        // Add new product
        await ProductService().addDocument(_product);
        NotificationService().showSuccess(Strings.productAddedSuccessfully);
      }
    } catch (e) {
      NotificationService().showSuccess(Strings.anErrorOccurred);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
