import 'package:flutter/material.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:sidebarx/sidebarx.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({required this.context});

  ThemeData getTheme() {
    // You can use the context here if needed
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: AppColors.primaryColor,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: AppColors.appBarBG,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.appbarTitleColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
      // drawerTheme: Theme.of(context).drawerTheme.copyWith(
      //       backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      //     ),
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // useMaterial3: false,
      textTheme: Theme.of(context).textTheme.copyWith(

      ),
      inputDecorationTheme: InputDecorationTheme(
        suffixIconColor: AppColors.textFieldBorderColor,
        prefixIconColor: AppColors.textFieldBorderColor,
        filled: true,
        fillColor: AppColors.textFieldBGColor,
        border: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFieldBorderColor.withOpacity(0.3), // Border color
            width: 1.0, // Border width
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFieldBorderColor.withOpacity(0.3), // Border color
            width: 1.0, // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: textFieldBorderRadius,
          borderSide: BorderSide(
            color: AppColors.textFocusedBorderColor.withOpacity(0.5),
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

  SidebarXTheme getSideBarDark() {
    return SidebarXTheme(
      // margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: canvasColor,
        // borderRadius: BorderRadius.circular(0),
      ),
      hoverColor: scaffoldBackgroundColor,
      textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      selectedTextStyle: const TextStyle(color: Colors.white),
      hoverTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      itemTextPadding: const EdgeInsets.only(right: 30),
      selectedItemTextPadding: const EdgeInsets.only(right: 30),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: canvasColor),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: actionColor.withOpacity(0.37),
        ),
        gradient: const LinearGradient(
          colors: [accentCanvasColor, canvasColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 30,
          )
        ],
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.7),
        size: 20,
      ),
      selectedIconTheme: const IconThemeData(
        color: Colors.white,
        size: 20,
      ),
    );
  }

  SidebarXTheme getSideBarLight() {
    return SidebarXTheme(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: canvasColorLight,
        borderRadius: BorderRadius.circular(20),
      ),
      hoverColor: scaffoldBackgroundColorLight,
      textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      selectedTextStyle: const TextStyle(color: Colors.white),
      hoverTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      itemTextPadding: const EdgeInsets.only(right: 30),
      selectedItemTextPadding: const EdgeInsets.only(right: 30),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: canvasColor),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: actionColor.withOpacity(0.37),
        ),
        gradient: const LinearGradient(
          colors: [accentCanvasColor, canvasColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 30,
          )
        ],
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.7),
        size: 20,
      ),
      selectedIconTheme: const IconThemeData(
        color: Colors.white,
        size: 20,
      ),
    );
  }

  SidebarXTheme getExtendedDarkTheme() {
    return const SidebarXTheme(
      width: 200,
      decoration: BoxDecoration(
        color: canvasColor,
      ),
    );
  }
}
