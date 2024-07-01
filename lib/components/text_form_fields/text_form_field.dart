import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/values/strings.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? label, validationMessage, value, initialValue;
  final IconData? suffixIcon;
  final bool? readOnly, enabled;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final bool canBeEmpty, displaySuffix;
  final int? minLength;
  final int? maxLength;
  final String? regexPattern;
  final Map<String, String Function(String?)>? customValidators;

  const CustomTextFormField(
      {super.key,
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
      this.initialValue,
      this.canBeEmpty = true,
      this.minLength,
      this.maxLength,
      this.regexPattern,
      this.customValidators,
      this.displaySuffix = true});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller?.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (widget.keyboardType == TextInputType.number) {
        GeneralFormatter.formatNumber(widget.controller?.text ?? '');
      } else if (widget.keyboardType == TextInputType.phone) {
        GeneralFormatter.formatPhoneNumber(widget.controller?.text ?? '');
      }
    }
  }

  Widget clearIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          widget.controller!.clear();
        },
      ),
    );
  }

  String? _generalValidator(String? value) {
    String? rawValue = value;
    if (widget.keyboardType == TextInputType.number) {
      rawValue = value?.replaceAll(',', '');
    }

    if (!widget.canBeEmpty && (rawValue == null || rawValue.isEmpty)) {
      return widget.validationMessage ?? 'This field cannot be empty';
    }

    if (widget.minLength != null &&
        rawValue != null &&
        rawValue.length < widget.minLength!) {
      return 'Minimum length is ${widget.minLength}';
    }

    if (widget.maxLength != null &&
        rawValue != null &&
        rawValue.length > widget.maxLength!) {
      return 'Maximum length is ${widget.maxLength}';
    }

    if (widget.regexPattern != null &&
        rawValue != null &&
        !RegExp(widget.regexPattern!).hasMatch(rawValue)) {
      return 'Invalid format';
    }

    if (widget.customValidators != null &&
        widget.customValidators!.containsKey(widget.label)) {
      return widget.customValidators![widget.label]!(rawValue);
    }

    switch (widget.keyboardType) {
      case TextInputType.number:
        if (rawValue != null && double.tryParse(rawValue) == null) {
          return widget.label == Strings.balance
              ? null
              : widget.validationMessage ?? 'Invalid number';
        }
        break;
      case TextInputType.phone:
        final digitsOnly = rawValue!.replaceAll(RegExp(r'\D'), '');
        if (widget.canBeEmpty && digitsOnly.isEmpty) {
          return null;
        }
        if (digitsOnly.length != 10) {
          return widget.validationMessage ?? 'Invalid phone number';
        }
        break;
      case TextInputType.emailAddress:
        if (rawValue != null &&
            rawValue.isNotEmpty &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(rawValue)) {
          return widget.validationMessage ?? 'Invalid email address';
        }
        break;
      case TextInputType.url:
        if (rawValue != null &&
            rawValue.isNotEmpty &&
            !RegExp(r'^www\.[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$').hasMatch(rawValue)) {
          return widget.validationMessage ?? 'Invalid website URL';
        } else {
          return null;
        }
        break;
      default:
        if (rawValue == null || rawValue.isEmpty) {
          return widget.validationMessage ?? 'This field cannot be empty';
        }
        break;
    }

    if (widget.label == Strings.amount &&
        (rawValue == '0' || rawValue == '0.0')) {
      return widget.validationMessage ?? 'Amount cannot be zero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> inputFormatters =
        widget.keyboardType == TextInputType.number
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;
                  return text.isEmpty
                      ? newValue
                      : double.tryParse(text) == null
                          ? oldValue
                          : newValue;
                }),
              ]
            : widget.keyboardType == TextInputType.phone
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
                    LengthLimitingTextInputFormatter(10),
                    CustomPhoneNumberFormatter()
                  ]
                : [];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        textDirection: widget.keyboardType == TextInputType.number ||
                widget.keyboardType == TextInputType.phone
            ? TextDirection.ltr
            : TextDirection.rtl,
        textAlign: TextAlign.right,
        enabled: widget.enabled,
        controller: widget.controller,
        style: widget.textStyle,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: widget.displaySuffix
              ? widget.suffixIcon != null
                  ? Icon(widget.suffixIcon)
                  : clearIcon()
              : null,
        ),
        readOnly: widget.readOnly ?? false,
        onTap: widget.onTap,
        onSaved: widget.onSaved,
        validator: _generalValidator,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        inputFormatters: inputFormatters,
        focusNode: _focusNode,
      ),
    );
  }
}

// Custom phone number formatter with Persian digit conversion
class CustomPhoneNumberFormatter extends TextInputFormatter {
  final RegExp _digitsOnly = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final length = digitsOnly.length;

    String formattedNumber;
    if (length <= 4) {
      formattedNumber = digitsOnly;
    } else if (length <= 7) {
      formattedNumber =
          '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
    } else {
      formattedNumber =
          '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
    }

    return newValue.copyWith(
      text: formattedNumber,
      selection: TextSelection.collapsed(offset: formattedNumber.length),
    );
  }
}
