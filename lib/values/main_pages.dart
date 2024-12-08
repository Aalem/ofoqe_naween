import 'package:flutter/material.dart';
import 'package:ofoqe_naween/screens/buys/buys.dart';
import 'package:ofoqe_naween/screens/buys/pages/add_invoice.dart';
import 'package:ofoqe_naween/screens/customers/customers.dart';
import 'package:ofoqe_naween/screens/money_exchange/pages/money_exchange_home.dart';
import 'package:ofoqe_naween/screens/page_under_construction.dart';
import 'package:ofoqe_naween/screens/suppliers/suppliers.dart';
import 'strings.dart';

var mainPages = {
  'customers' : {'title': Strings.customers, 'icon': Icons.people, 'widget':  const CustomersPage()},
  'suppliers' : {'title': Strings.suppliers, 'icon': Icons.factory, 'widget': const SuppliersPage()},
  'buys' : {'title': Strings.buys, 'icon': Icons.kitchen, 'widget': BuysPage()},
  'inventory' : {'title': Strings.inventory, 'icon': Icons.inventory, 'widget': UnderConstructionPage()},
  'money_exchange' : {'title': Strings.moneyExchange, 'icon': Icons.money, 'widget': MoneyExchangeHome()},
};