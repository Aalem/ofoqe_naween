import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  final String title;

  const AppbarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
