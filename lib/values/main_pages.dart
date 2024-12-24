import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/products/pages/products_home.dart';
import 'package:ofoqe_naween/pages/purchases/purchases.dart';
import 'package:ofoqe_naween/pages/customers/customers.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/money_exchange_home.dart';
import 'package:ofoqe_naween/pages/page_under_construction.dart';
import 'package:ofoqe_naween/pages/suppliers/suppliers.dart';
import 'strings.dart';

var mainPages = {
  'customers' : {'title': Strings.customers, 'icon': Icons.people, 'widget':  const CustomersPage()},
  'products' : {'title': Strings.products, 'icon': Icons.iron_sharp, 'widget':  ProductsHomePage()},
  'suppliers' : {'title': Strings.suppliers, 'icon': Icons.factory, 'widget': const SuppliersPage()},
  'purchases' : {'title': Strings.buys, 'icon': Icons.kitchen, 'widget': PurchasesPage()},
  'inventory' : {'title': Strings.inventory, 'icon': Icons.inventory, 'widget': UnderConstructionPage()},
  'money_exchange' : {'title': Strings.moneyExchange, 'icon': Icons.money, 'widget': MoneyExchangeHome()},
};