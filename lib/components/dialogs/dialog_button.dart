import 'package:flutter/material.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';

class DialogButton extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final ButtonType? buttonType;
  final Widget? child;
  const DialogButton({super.key, this.title, this.onPressed, this.buttonType, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          foregroundColor: Colors.white,
          backgroundColor: buttonType == ButtonType.positive ? Theme.of(context).primaryColor : Colors.redAccent,
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        child: child ?? Text(title!),
      ),
    );
  }
}
