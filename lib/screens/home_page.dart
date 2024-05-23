import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/screens/customers/customers.dart';
import 'package:ofoqe_naween/screens/money_exchange/money_exchange.dart';
import 'package:ofoqe_naween/screens/page_under_construction.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for drawer

  void _logout() async {
    // Implement logout functionality here
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NavigationProvider.instance.contentToDisplay = CustomersPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MediaQuery.of(context).size.width < 600
          ? _buildAppBar(context)
          : null,
      endDrawer: _buildDrawer(context),
      body: Row(
        children: [
          contentWidget(),
          Visibility(
            visible: MediaQuery.of(context).size.width > 600,
            child: _buildDrawer(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Row(
        children: [
          Expanded(child: Text(Strings.appName, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState
              ?.openEndDrawer(), // Open drawer on mobile
        ),
      ],
    );
  }

  Widget contentWidget() {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        return Expanded(child: provider.contentToDisplay);
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      clipBehavior: Clip.none,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, // Customize header color
              ),
              child: const Text(
                Strings.appName,
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text(Strings.inventory),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(UnderConstructionPage()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text(Strings.customers),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(CustomersPage()),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text(Strings.ledger),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(UnderConstructionPage()),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text(Strings.journal),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(UnderConstructionPage()),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text(Strings.moneyExchange),
              onTap: () =>
                  // Provider.of<NavigationProvider>(context, listen: false)
                  //     .updatePage(MoneyExchange()),
              Provider.of<NavigationProvider>(context, listen: false)
                  .updatePage(UnderConstructionPage()),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(Strings.logout),
              // onTap: () => _showLogoutConfirmation(),
            ),
          ],
        ),
      ),
    );
  }
}
