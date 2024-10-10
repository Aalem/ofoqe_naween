import 'package:flutter/material.dart';

class ResponsiveHelper {
  static List<Widget> genResponsiveTwoWidgets(
      List<Widget> widgets, BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        ? [
            Row(
              children: [
                  Expanded(child: widgets.first),
                Expanded(child: widgets.last),
              ],
            )
          ]
        : widgets;
  }
}
