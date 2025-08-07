import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/exchanges.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/transactions.dart';
import 'package:ofoqe_naween/pages/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/pages/products/pages/brands.dart';
import 'package:ofoqe_naween/pages/products/pages/categories.dart';
import 'package:ofoqe_naween/pages/products/pages/products.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/values/strings.dart';

class ProductsHomePage extends StatefulWidget {
  @override
  _ProductsHomePageState createState() => _ProductsHomePageState();
}

class _ProductsHomePageState extends State<ProductsHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text(Strings.productsAndCategories),
            bottom: const TabBar(
              tabs: [
                Tab(text: Strings.products),
                Tab(text: Strings.categories),
                Tab(text: Strings.brands),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ProductsPage(),
              CategoriesPage(),
              BrandsPage(),
            ],
          )),
    );
  }
}
