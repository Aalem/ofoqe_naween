import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  const ButtonIcon({super.key, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
