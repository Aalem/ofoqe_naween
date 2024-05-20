import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ofoqe_naween/screens/money_exchange/providers/balance_provider.dart';
import 'package:provider/provider.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? label, validationMessage, value;
  final IconData? suffixIcon;
  final bool? readOnly, enabled;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.readOnly,
    this.onTap,
    this.onChanged,
    this.onSaved,
    this.enabled,
    this.validationMessage,
    this.suffixIcon,
    this.value,
    this.keyboardType,
    this.textStyle,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    print(Provider.of<BalanceProvider>(context).balance);
    final List<TextInputFormatter> inputFormatters =
        widget.keyboardType == TextInputType.number
            ? [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;
                  return text.isEmpty
                      ? newValue
                      : double.tryParse(text) == null
                          ? oldValue
                          : newValue;
                }),
              ]
            : [];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        // initialValue: widget.value,
        enabled: widget.enabled,
        controller: widget.controller,
        style: widget.textStyle,
        decoration: InputDecoration(
            labelText: widget.label, suffixIcon: Icon(widget.suffixIcon)),
        readOnly: widget.readOnly ?? false,
        onTap: widget.onTap,
        onSaved: widget.onSaved,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return widget.validationMessage;
          }
          return null;
        },
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
