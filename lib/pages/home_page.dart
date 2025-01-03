import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ofoqe_naween/pages/products/pages/products_home.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/theme.dart';
import 'package:ofoqe_naween/values/main_pages.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedKey = 'suppliers';
  SidebarXController sidebarXController = SidebarXController(selectedIndex: 0);
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
    super.initState();
    NavigationProvider.instance.contentToDisplay = ProductsHomePage() ;
    sidebarXController.setExtended(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: pagesize.isPhone(context) ? _buildAppBar(context) : null,
      appBar: ResponsiveBreakpoints.of(context).isMobile
          ? _buildAppBar(context)
          : null,
      endDrawer: _buildDrawer(context),
      body: Row(
        children: [
          Visibility(
            // visible: !pagesize.isPhone(context),
            visible: !ResponsiveBreakpoints.of(context).isMobile,
            child: _buildDrawer(context),
          ),
          contentWidget(),
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

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return SidebarX(
      theme: AppTheme(context: context).getSideBarDark(),
      extendedTheme: AppTheme(context: context).getExtendedDarkTheme(),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 150,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset('assets/images/logo_light.svg')),
        );
      },
      controller: sidebarXController,
      items: [
        ...mainPages.keys.map((String key) {
          return SidebarXItem(
            icon: mainPages[key]!['icon'] as IconData,
            label: mainPages[key]!['title'] as String,
            onTap: () {
              NavigationProvider.selectedKey = key;
              Provider.of<NavigationProvider>(context, listen: false)
                  .updatePage(mainPages[key]!['widget'] as Widget);
            },
          );
        }),
        // SidebarXItem(),
        SidebarXItem(
          icon: Icons.home,
          label: Strings.logout,
          onTap: () {
            debugPrint('Logout');
          },
        ),
      ],
    );
  }
}
