import 'package:flutter/material.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/screens/suppliers/suppliers.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/utilities/screen_size.dart';
import 'package:ofoqe_naween/values/main_pages.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedKey = 'suppliers';
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
    NavigationProvider.instance.contentToDisplay = SuppliersPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: ScreenSize.isPhone(context) ? _buildAppBar(context) : null,
      endDrawer: _buildDrawer(context),
      body: Row(
        children: [
          contentWidget(),
          Visibility(
            visible: !ScreenSize.isPhone(context),
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
          Expanded(
              child: Text(
            Strings.appName,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
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
            ...mainPages.keys.map((String key) {
              return Consumer<NavigationProvider>(
                builder: (context, navigationProvider, child) {
                  bool isSelected = NavigationProvider.selectedKey == key;
                  return ListTile(
                    leading: Icon(mainPages[key]!['icon'] as IconData,
                        color: isSelected ? AppColors.primaryColor : null),
                    title: Text(
                      mainPages[key]!['title'] as String,
                      style: isSelected
                          ? TextStyle(color: AppColors.primaryColor)
                          : null,
                    ),
                    tileColor: isSelected ? Colors.grey[300] : null,
                    onTap: () {
                      NavigationProvider.selectedKey = key;
                      Provider.of<NavigationProvider>(context, listen: false)
                          .updatePage(mainPages[key]!['widget'] as Widget);
                    },
                  );
                },
              );
            }),
            const ListTile(
              leading: Icon(Icons.logout),
              title: Text(Strings.logout),
              // onTap: () => _showLogoutConfirmation(),
            ),
          ],
        ),
      ),
    );
  }
}
