import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/customers/models/customer_model.dart';
import 'package:ofoqe_naween/pages/customers/services/customer_service.dart';
import 'package:ofoqe_naween/values/strings.dart';

import '../generic/generic_add_page.dart';

class NewCustomerPage extends StatefulWidget {
  final Customer? customer;
  final String? id;

  const NewCustomerPage({super.key, this.customer, this.id});

  @override
  _NewCustomerPageState createState() => _NewCustomerPageState();
}

class _NewCustomerPageState extends State<NewCustomerPage> {
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer ??
        Customer(
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

  @override
  Widget build(BuildContext context) {
    return GenericAddPage<Customer>(
      model: _customer,
      id: widget.id,
      fields: [
        FieldConfig(
          label: Strings.company,
          initialValue: _customer.company,
          validationMessage: Strings.enterCompany,
          onSaved: (value) => _customer.company = value!,
        ),
        FieldConfig(
          label: Strings.customerName,
          initialValue: _customer.name,
          validationMessage: Strings.enterName,
          onSaved: (value) => _customer.name = value!,
        ),
        FieldConfig(
          label: Strings.address,
          initialValue: _customer.address,
          validationMessage: Strings.enterAddress,
          onSaved: (value) => _customer.address = value!,
        ),
        FieldConfig(
          label: Strings.phone1,
          initialValue: _customer.phone1,
          validationMessage: Strings.enterCorrectNumber,
          canBeEmpty: true,
          keyboardType: TextInputType.phone,
          onSaved: (value) => _customer.phone1 = value!,
        ),
        FieldConfig(
          label: Strings.phone2,
          initialValue: _customer.phone2,
          validationMessage: Strings.enterCorrectNumber,
          canBeEmpty: true,
          keyboardType: TextInputType.phone,
          onSaved: (value) => _customer.phone2 = value!,
        ),
        FieldConfig(
          label: Strings.email,
          initialValue: _customer.email,
          validationMessage: Strings.enterValidEmail,
          keyboardType: TextInputType.emailAddress,
          onSaved: (value) => _customer.email = value!,
        ),
      ],
      saveService: (customer, id) async {
        if (id != null) {
          await CustomerService().updateDocument(id, customer);
        } else {
          await CustomerService().addDocument(customer);
        }
      },
      addTitle: Strings.add  + Strings.newCustomer,
      editTitle: Strings.edit + Strings.customer,
      addSuccessMessage: Strings.customerAddedSuccessfully,
      editSuccessMessage: Strings.customerUpdatedSuccessfully,
      errorMessage: widget.id != null ? Strings.errorUpdatingCustomer : Strings.errorAddingCustomer,
    );
  }
}