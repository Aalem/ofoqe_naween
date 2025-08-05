import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/pages/customers/add_customer.dart';
import 'package:ofoqe_naween/pages/customers/collection_fields/customer_fields.dart';
import 'package:ofoqe_naween/pages/customers/models/customer_model.dart';
import 'package:ofoqe_naween/pages/customers/services/customer_service.dart';
import 'package:ofoqe_naween/utilities/data-tables/generic_datatable.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCustomers() {
    return _firestore
        .collection(CollectionNames.customers)
        .orderBy(CustomerFields.name, descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.customers), // Changed to reflect customers
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
          DataColumn(label: Text(Strings.number)), // Non-sortable
          DataColumn(label: Text(Strings.company)),
          DataColumn(label: Text(Strings.customerName)),
          DataColumn(label: Text(Strings.phoneNumbers)),
          DataColumn(label: Text(Strings.address)),
          DataColumn(label: Text(Strings.actions)), // Non-sortable
        ],
        dataStream: _getCustomers(),
        fromMap: (data, id) => Customer.fromMap(data, id),
        deleteService: CustomerService().deleteDocument,
        addEditWidget: ({Customer? model, String? id}) => NewCustomerPage(customer: model, id: id),
        cellBuilder: (Customer customer) => [
          DataCell(Text(customer.company)),
          DataCell(Text(customer.name)),
          DataCell(
            Text(
              '${customer.phone1}${customer.phone2.isNotEmpty == true ? '\n${customer.phone2}' : ''}',
              textDirection: TextDirection.ltr,
            ),
          ),
          DataCell(Text(customer.address)),
        ],
        addTitle: Strings.addCustomerTitle,
        deleteTitlePrefix: Strings.customerDeleteTitle,
        deleteMessage: Strings.customerDeleteMessage,
        deleteSuccessMessage: Strings.customerDeleteMessage,
        deleteFailureMessage: Strings.errorDeletingCustomer,
        enableSearch: true,
        enableSort: true,
        searchFields: const [CustomerFields.company, CustomerFields.name],
        sortFields: [
              (Customer c) => c.company,
              (Customer c) => c.name,
        ],
      ),
    );
  }
}