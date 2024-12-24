import 'package:flutter/material.dart';

class pagesize {
  static double measureWidgetWidth(GlobalKey widgetKey) {
    RenderBox renderBox = widgetKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.width;
  }


  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenAspectRatio(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio;
  }
}
