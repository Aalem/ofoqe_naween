import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/firebase_options.dart';
import 'package:ofoqe_naween/providers/navigation_provider.dart';
import 'package:ofoqe_naween/screens/home_page.dart';
import 'package:ofoqe_naween/screens/ledger/add_to_ledger.dart';
import 'package:ofoqe_naween/screens/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ChangeNotifierProvider<NavigationProvider>(
        create: (context) => NavigationProvider(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            // useMaterial3: true,
            // useMaterial3: false,
          ),
          initialRoute: '/home',
          // initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
          // home:
          //     FirebaseAuth.instance.currentUser != null ? HomePage() : LoginPage(),
          routes: {
            '/home': (context) => HomePage(),
            '/login': (context) => LoginPage(),
            '/ledger': (context) => AddLedgerEntry(),
          },
        ),
      ),
    );
  }
}
