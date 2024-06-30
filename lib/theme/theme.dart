import 'package:flutter/material.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/constants.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({required this.context});

  ThemeData getTheme() {
    // You can use the context here if needed
    return ThemeData(
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: AppColors.appBarBG,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
      drawerTheme: Theme.of(context).drawerTheme.copyWith(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // useMaterial3: false,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.textFieldBGColor,
        border: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFieldBorderColor, // Border color
            width: 1.0, // Border width
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFieldBorderColor, // Border color
            width: 1.0, // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFocusedBorderColor,
            // Border color when focused
            width: 1.0, // Border width when focused
          ),
        ),
        // Add any other input decoration properties you want to customize
      ),
    );
  }

  //  ThemeData lightTheme = ThemeData(
  //   appBarTheme: Theme.of(context).appBarTheme.copyWith(
  //       elevation: 0,
  //       backgroundColor: Colors.grey.shade200,
  //       titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20)
  //   ),
  //   drawerTheme: Theme.of(context).drawerTheme.copyWith(
  //     backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
  //   ),
  //   // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  //   // useMaterial3: false,
  // );
  ThemeData darkTheme = ThemeData(
    // Define dark theme properties here
    primaryColor: Colors.indigo,
    // Other theme properties...
  );
}
