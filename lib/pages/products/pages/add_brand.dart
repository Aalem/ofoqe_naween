import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/products/models/brand.dart';
import 'package:ofoqe_naween/pages/products/services/brand_service.dart';
import 'package:ofoqe_naween/values/strings.dart';

import '../../generic/generic_add_page.dart';

class AddBrandPage extends StatefulWidget {
  final BrandModel? brand;
  final String? id;

  const AddBrandPage({super.key, this.brand, this.id});

  @override
  _AddBrandPageState createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  late BrandModel _brand;

  @override
  void initState() {
    super.initState();
    _brand = widget.brand ?? BrandModel();
  }

  @override
  Widget build(BuildContext context) {
    return GenericAddPage<BrandModel>(
      model: _brand,
      id: widget.id,
      fields: [
        FieldConfig(
          label: Strings.brandName,
          initialValue: _brand.name,
          validationMessage: Strings.enterBrandName,
          onSaved: (value) => _brand.name = value!,
        ),
        FieldConfig(
          label: Strings.description,
          initialValue: _brand.description,
          onSaved: (value) => _brand.description = value!,
        ),
        FieldConfig(
          label: Strings.country,
          initialValue: _brand.country,
          onSaved: (value) => _brand.country = value!,
        ),
      ],
      saveService: (brand, id) async {
        if (id != null) {
          await BrandService().updateDocument(id, brand);
        } else {
          await BrandService().addDocument(brand);
        }
      },
      addTitle: Strings.add + Strings.brand,
      editTitle: Strings.edit + Strings.brand,
      addSuccessMessage: Strings.brandAddedSuccessfully,
      editSuccessMessage: Strings.brandUpdatedSuccessfully,
      errorMessage: Strings.anErrorOccurred,
    );
  }
}