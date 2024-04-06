import 'package:flutter/material.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/screens/ledger/ledger.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';

import 'login_page.dart'; // Import for icons

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
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: _logout,
              child: Text('Logout'),
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
    NavigationProvider.instance.contentToDisplay = LedgerPage();
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
      title: Text(Strings.appName),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
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
              child: Text(
                Strings.appName,
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, // Customize header color
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text(Strings.inventory),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(LoginPage()),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(Strings.ledger),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(LedgerPage()),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text(Strings.journal),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(LedgerPage()),
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text(Strings.bank),
              onTap: () =>
                  Provider.of<NavigationProvider>(context, listen: false)
                      .updatePage(LoginPage()),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(Strings.logout),
              onTap: () => _showLogoutConfirmation(),
            ),
          ],
        ),
      ),
    );
  }
}
