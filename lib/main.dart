import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/firebase_options.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/pages/purchases/purchases.dart';
import 'package:ofoqe_naween/pages/home_page.dart';
import 'package:ofoqe_naween/pages/ledger/add_to_ledger.dart';
import 'package:ofoqe_naween/pages/login_page.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/money_exchange_home.dart';
import 'package:ofoqe_naween/theme/theme.dart';
import 'package:ofoqe_naween/utilities/screen_size.dart';
import 'package:ofoqe_naween/values/strings.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationProvider>(
      create: (context) => NavigationProvider(),
      child: MaterialApp(
        scrollBehavior:
            pagesize.isDesktop(context) ? MyCustomScrollBehavior() : null,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
          child:
              Directionality(textDirection: TextDirection.rtl, child: child!),
        ),
        title: Strings.appName,
        theme: AppTheme(context: context).getTheme(),
        initialRoute: '/home',
        // initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
        // home:
        //     FirebaseAuth.instance.currentUser != null ? HomePage() : LoginPage(),
        routes: {
          '/home': (context) => HomePage(),
          '/login': (context) => LoginPage(),
          '/ledger': (context) => AddLedgerEntry(),
          '/buys': (context) => PurchasesPage(),
          '/money_exchange': (context) => MoneyExchangeHome(),
        },
      ),
    );
  }
}
