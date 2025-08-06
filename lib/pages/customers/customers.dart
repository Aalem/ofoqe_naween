import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/customers/add_customer.dart';
import 'package:ofoqe_naween/pages/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/pages/customers/services/customer_service.dart';
import 'package:ofoqe_naween/pages/customers/models/customer_model.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/strings.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.customers),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text(Strings.addCustomerTitle),
                content: NewCustomerPage(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: GenericDataTable<Customer>(
        columns: const [
          DataColumn(label: Text(Strings.number), numeric: true),
          DataColumn(
            label: Text(Strings.company),
            onSort: null, // Sorting handled by GenericDataTable
          ),
          DataColumn(
            label: Text(Strings.customerName),
            onSort: null,
          ),
          DataColumn(label: Text(Strings.phoneNumbers)),
          DataColumn(label: Text(Strings.address)),
          DataColumn(label: Text(Strings.actions)),
        ],
        dataStream: CustomerService().getDocumentsStream(),
        fromMap: (data, id) => Customer.fromMap(data, id),
        deleteService: CustomerService().deleteDocument,
        addEditWidget: ({Customer? model, String? id}) => NewCustomerPage(customer: model, id: id),
        cellBuilder: (Customer customer) => [
          DataCell(Text(customer.company)),
          DataCell(Text(customer.name)),
          DataCell(Text(
            textDirection: TextDirection.ltr,
            '${customer.phone1} ${customer.phone2.isNotEmpty ? '\n${customer.phone2}' : ''}',
          )),
          DataCell(Text(customer.address)),
        ],
        addTitle: Strings.addCustomerTitle,
        deleteTitlePrefix: Strings.customerDeleteTitle,
        deleteMessage: Strings.customerDeleteMessage,
        deleteSuccessMessage: 'Customer deleted successfully',
        deleteFailureMessage: 'Failed to delete customer',
        enableSearch: true,
        enableSort: true,
        searchFields: const [CustomerFields.company, CustomerFields.name],
        sortFields: [
              (c) => c.company,
              (c) => c.name,
        ],
      ),
    );
  }
}