import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveHelper {
  static List<Widget> genResponsiveWidgets(
      List<Widget> widgets, BuildContext context) {
    return ResponsiveBreakpoints.of(context).isDesktop
        ? [
            Row(
              children: List.generate(
                widgets.length,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == widgets.length - 1
                          ? 0.0
                          : 8.0, // No padding for the last widget
                    ),
                    child: widgets[index],
                  ),
                ),
              ),
            ),
          ]
        : widgets;
  }
}
