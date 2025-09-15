// import 'package:flutter/material.dart';
// import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
// import 'package:ofoqe_naween/components/dropdowns/simple_dropdown.dart';
// import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
// import 'package:ofoqe_naween/pages/products/models/category.dart';
// import 'package:ofoqe_naween/pages/products/models/product.dart';
// import 'package:ofoqe_naween/pages/products/models/brand.dart';
// import 'package:ofoqe_naween/pages/products/services/category_service.dart';
// import 'package:ofoqe_naween/pages/products/services/product_service.dart';
// import 'package:ofoqe_naween/pages/products/services/brand_service.dart';
// import 'package:ofoqe_naween/services/notification_service.dart';
// import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
// import 'package:ofoqe_naween/values/enums/enums.dart';
// import 'package:ofoqe_naween/values/strings.dart';
//
// class AddProductPage extends StatefulWidget {
//   final Product? product;
//   final String? id;
//
//   const AddProductPage({super.key, this.product, this.id});
//
//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }
//
// class _AddProductPageState extends State<AddProductPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   CategoryModel? _selectedCategory;
//   BrandModel? _selectedBrand;
//   late Product _product;
//
//   // Declare TextEditingControllers
//   late TextEditingController _nameController;
//   late TextEditingController _codeController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _unitController;
//   late TextEditingController _modelController;
//   late TextEditingController _colorController;
//   late TextEditingController _warrantyController;
//   late TextEditingController _dimensionController;
//   late TextEditingController _weightController;
//
//   @override
//   void initState() {
//     super.initState();
//     _product = widget.product ?? Product();
//
//     // Initialize TextEditingControllers with initial values
//     _nameController = TextEditingController(text: _product.name);
//     _codeController = TextEditingController(text: _product.code);
//     _descriptionController = TextEditingController(text: _product.description);
//     _unitController = TextEditingController(text: _product.unit);
//     _modelController = TextEditingController(text: _product.model);
//     _colorController = TextEditingController(text: _product.color);
//     _warrantyController = TextEditingController(text: _product.warranty);
//     _dimensionController = TextEditingController(text: _product.dimension);
//     _weightController = TextEditingController(text: _product.weight?.toString() ?? '');
//   }
//
//   @override
//   void dispose() {
//     // Dispose of all controllers to prevent memory leaks
//     _nameController.dispose();
//     _codeController.dispose();
//     _descriptionController.dispose();
//     _unitController.dispose();
//     _modelController.dispose();
//     _colorController.dispose();
//     _warrantyController.dispose();
//     _dimensionController.dispose();
//     _weightController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width > 600
//           ? MediaQuery.of(context).size.width / 2
//           : MediaQuery.of(context).size.width,
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ...ResponsiveHelper.genResponsiveWidgets([
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productName,
//                   controller: _nameController,
//                   validationMessage: Strings.enterProductName,
//                   onSaved: (value) => _product.name = value!,
//                 ),
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productCode,
//                   controller: _codeController,
//                   onSaved: (value) => _product.code = value!,
//                 ),
//               ], context),
//
//               CustomTextFormField(
//                 enabled: !_isLoading,
//                 label: Strings.description,
//                 controller: _descriptionController,
//                 onSaved: (value) => _product.description = value!,
//                 maxLines: 2,
//               ),
//
//               ...ResponsiveHelper.genResponsiveWidgets([
//                 StreamBuilder<List<CategoryModel>>(
//                   stream: CategoryService()
//                       .getDocumentsStream()
//                       .map((snapshot) => snapshot.docs
//                       .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
//                       .toList()),
//                   builder: (context, snapshot) {
//                     final categories = snapshot.data ?? [];
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     return SimpleDropdown<CategoryModel>(
//                       label: Strings.chooseCategory,
//                       items: categories,
//                       selectedValue: _selectedCategory?.id,
//                       getLabel: (c) => c.name ?? '',
//                       getValue: (c) => c.id!,
//                       onChanged: (val) {
//                         setState(() {
//                           _selectedCategory = categories.firstWhere((c) => c.id == val);
//                         });
//                       },
//                       validator: (val) => val == null ? Strings.chooseCategory : null,
//                     );
//                   },
//                 ),
//                 StreamBuilder<List<BrandModel>>(
//                   stream: BrandService()
//                       .getDocumentsStream()
//                       .map((snapshot) => snapshot.docs
//                       .map((doc) => BrandModel.fromMap(doc.data(), doc.id))
//                       .toList()),
//                   builder: (context, snapshot) {
//                     final brands = snapshot.data ?? [];
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     return SimpleDropdown<BrandModel>(
//                       label: Strings.productBrand,
//                       items: brands,
//                       selectedValue: _selectedBrand?.id,
//                       getLabel: (b) => b.name ?? '',
//                       getValue: (b) => b.id!,
//                       onChanged: (val) {
//                         setState(() {
//                           _selectedBrand = brands.firstWhere((b) => b.id == val);
//                         });
//                       },
//                       validator: (val) => val == null ? Strings.select + Strings.brand : null,
//                     );
//                   },
//                 ),
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productUnit,
//                   controller: _unitController,
//                   validationMessage: Strings.enterProductUnit,
//                   onSaved: (value) => _product.unit = value!,
//                 ),
//               ], context),
//               ...ResponsiveHelper.genResponsiveWidgets([
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productModel,
//                   controller: _modelController,
//                   onSaved: (value) => _product.model = value!,
//                 ),
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productColor,
//                   controller: _colorController,
//                   onSaved: (value) => _product.color = value!,
//                 ),
//               ], context),
//               ...ResponsiveHelper.genResponsiveWidgets([
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productWarranty,
//                   controller: _warrantyController,
//                   onSaved: (value) => _product.warranty = value!,
//                 ),
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productDimension,
//                   controller: _dimensionController,
//                   onSaved: (value) => _product.dimension = value!,
//                 ),
//                 CustomTextFormField(
//                   enabled: !_isLoading,
//                   label: Strings.productWeight,
//                   controller: _weightController,
//                   keyboardType: TextInputType.number,
//                   onSaved: (value) => _product.weight = double.tryParse(value!) ?? 0.0,
//                 ),
//               ], context),
//
//               const SizedBox(height: 20.0),
//
//               Row(
//                 children: [
//                   Expanded(
//                     child: DialogButton(
//                       buttonType: ButtonType.positive,
//                       title: Strings.save,
//                       onPressed: _isLoading
//                           ? null
//                           : () async {
//                         if (_formKey.currentState!.validate()) {
//                           _formKey.currentState!.save();
//                           await _saveProductToFirestore();
//                         }
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: DialogButton(
//                       buttonType: ButtonType.negative,
//                       title: Strings.cancel,
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text(Strings.dialogCancelTitle),
//                             content: const Text(Strings.dialogCancelMessage),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text(Strings.yes),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text(Strings.no),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _saveProductToFirestore() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     setState(() => _isLoading = true);
//
//     try {
//       _product.categoryId = _selectedCategory?.id;
//       _product.categoryName = _selectedCategory?.name;
//       _product.brandId = _selectedBrand?.id;
//       _product.brandName = _selectedBrand?.name;
//
//       if (widget.id != null) {
//         await ProductService().updateDocument(widget.id!, _product);
//         NotificationService().showSuccess(Strings.productUpdatedSuccessfully);
//       } else {
//         await ProductService().addDocument(_product);
//         NotificationService().showSuccess(Strings.productAddedSuccessfully);
//       }
//
//       Navigator.pop(context);
//     } catch (e) {
//       NotificationService().showError(Strings.anErrorOccurred);
//       setState(() => _isLoading = false);
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/dropdowns/simple_dropdown.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/pages/products/models/category.dart';
import 'package:ofoqe_naween/pages/products/models/product.dart';
import 'package:ofoqe_naween/pages/products/models/brand.dart';
import 'package:ofoqe_naween/pages/products/services/category_service.dart';
import 'package:ofoqe_naween/pages/products/services/product_service.dart';
import 'package:ofoqe_naween/pages/products/services/brand_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  final String? id;

  const AddProductPage({super.key, this.product, this.id});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CategoryModel? _selectedCategory;
  BrandModel? _selectedBrand;
  late Product _product;

  // Declare TextEditingControllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _warrantyController;
  late TextEditingController _dimensionController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? Product();

    // Initialize TextEditingControllers with initial values
    _nameController = TextEditingController(text: _product.name);
    _codeController = TextEditingController(text: _product.code);
    _descriptionController = TextEditingController(text: _product.description);
    _unitController = TextEditingController(text: _product.unit);
    _modelController = TextEditingController(text: _product.model);
    _colorController = TextEditingController(text: _product.color);
    _warrantyController = TextEditingController(text: _product.warranty);
    _dimensionController = TextEditingController(text: _product.dimension);
    _weightController = TextEditingController(text: _product.weight?.toString() ?? '');

    // Initialize selected category and brand for edit mode
    if (widget.product != null) {
      if (widget.product!.categoryId != null) {
        _selectedCategory = CategoryModel(id: widget.product!.categoryId, name: widget.product!.categoryName);
      }
      if (widget.product!.brandId != null) {
        _selectedBrand = BrandModel(id: widget.product!.brandId, name: widget.product!.brandName);
      }
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _warrantyController.dispose();
    _dimensionController.dispose();
    _weightController.dispose();
    super.dispose();
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
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productName,
                  controller: _nameController,
                  validationMessage: Strings.enterProductName,
                  onSaved: (value) => _product.name = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productCode,
                  controller: _codeController,
                  onSaved: (value) => _product.code = value!,
                ),
              ], context),

              CustomTextFormField(
                enabled: !_isLoading,
                label: Strings.description,
                controller: _descriptionController,
                onSaved: (value) => _product.description = value!,
                maxLines: 2,
              ),

              ...ResponsiveHelper.genResponsiveWidgets([
                StreamBuilder<List<CategoryModel>>(
                  stream: CategoryService()
                      .getDocumentsStream()
                      .map((snapshot) => snapshot.docs
                      .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
                      .toList()),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Update _selectedCategory with the latest data from the stream
                    if (_selectedCategory != null && categories.isNotEmpty) {
                      _selectedCategory = categories.firstWhere(
                            (c) => c.id == _selectedCategory!.id,
                        orElse: () => _selectedCategory!,
                      );
                    }
                    return SimpleDropdown<CategoryModel>(
                      label: Strings.chooseCategory,
                      items: categories,
                      selectedValue: _selectedCategory?.id,
                      getLabel: (c) => c.name ?? '',
                      getValue: (c) => c.id!,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = categories.firstWhere((c) => c.id == val);
                        });
                      },
                      validator: (val) => val == null ? Strings.chooseCategory : null,
                    );
                  },
                ),
                StreamBuilder<List<BrandModel>>(
                  stream: BrandService()
                      .getDocumentsStream()
                      .map((snapshot) => snapshot.docs
                      .map((doc) => BrandModel.fromMap(doc.data(), doc.id))
                      .toList()),
                  builder: (context, snapshot) {
                    final brands = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Update _selectedBrand with the latest data from the stream
                    if (_selectedBrand != null && brands.isNotEmpty) {
                      _selectedBrand = brands.firstWhere(
                            (b) => b.id == _selectedBrand!.id,
                        orElse: () => _selectedBrand!,
                      );
                    }
                    return SimpleDropdown<BrandModel>(
                      label: Strings.productBrand,
                      items: brands,
                      selectedValue: _selectedBrand?.id,
                      getLabel: (b) => b.name ?? '',
                      getValue: (b) => b.id!,
                      onChanged: (val) {
                        setState(() {
                          _selectedBrand = brands.firstWhere((b) => b.id == val);
                        });
                      },
                      validator: (val) => val == null ? Strings.select + Strings.brand : null,
                    );
                  },
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productUnit,
                  controller: _unitController,
                  validationMessage: Strings.enterProductUnit,
                  onSaved: (value) => _product.unit = value!,
                ),
              ], context),
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productModel,
                  controller: _modelController,
                  onSaved: (value) => _product.model = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productColor,
                  controller: _colorController,
                  onSaved: (value) => _product.color = value!,
                ),
              ], context),
              ...ResponsiveHelper.genResponsiveWidgets([
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productWarranty,
                  controller: _warrantyController,
                  onSaved: (value) => _product.warranty = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productDimension,
                  controller: _dimensionController,
                  onSaved: (value) => _product.dimension = value!,
                ),
                CustomTextFormField(
                  enabled: !_isLoading,
                  label: Strings.productWeight,
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _product.weight = double.tryParse(value!) ?? 0.0,
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
                          await _saveProductToFirestore();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: DialogButton(
                      buttonType: ButtonType.negative,
                      title: Strings.cancel,
                      onPressed: _isLoading
                          ? null
                          : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(Strings.dialogCancelTitle),
                            content: const Text(Strings.dialogCancelMessage),
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

  Future<void> _saveProductToFirestore() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      _product.categoryId = _selectedCategory?.id;
      _product.categoryName = _selectedCategory?.name;
      _product.brandId = _selectedBrand?.id;
      _product.brandName = _selectedBrand?.name;

      if (widget.id != null) {
        await ProductService().updateDocument(widget.id!, _product);
        NotificationService().showSuccess(Strings.productUpdatedSuccessfully);
      } else {
        await ProductService().addDocument(_product);
        NotificationService().showSuccess(Strings.productAddedSuccessfully);
      }

      Navigator.pop(context);
    } catch (e) {
      NotificationService().showError(Strings.anErrorOccurred);
      setState(() => _isLoading = false);
    }
  }
}