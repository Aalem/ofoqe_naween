// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:ofoqe_naween/values/strings.dart';
//
// class CustomTextFormField extends StatefulWidget {
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;
//   final String? label, validationMessage, value, initialValue;
//   final IconData? suffixIcon;
//   final bool? readOnly, enabled;
//   final TextStyle? textStyle;
//   final VoidCallback? onTap;
//   final void Function(String?)? onSaved;
//   final void Function(String?)? onChanged;
//   final bool canBeEmpty;
//   final int? minLength;
//   final int? maxLength;
//   final String? regexPattern;
//   final Map<String, String Function(String?)>? customValidators;
//
//   const CustomTextFormField({
//     Key? key,
//     this.controller,
//     required this.label,
//     this.readOnly,
//     this.onTap,
//     this.onChanged,
//     this.onSaved,
//     this.enabled,
//     this.validationMessage,
//     this.suffixIcon,
//     this.value,
//     this.keyboardType,
//     this.textStyle,
//     this.initialValue,
//     this.canBeEmpty = true,
//     this.minLength,
//     this.maxLength,
//     this.regexPattern,
//     this.customValidators,
//   }) : super(key: key);
//
//   @override
//   State<CustomTextFormField> createState() => _CustomTextFormFieldState();
// }
//
// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   Widget clearIcon() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           widget.controller!.clear();
//         },
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialValue != null) {
//       widget.controller?.text = widget.initialValue!;
//     }
//   }
//
//   String? _generalValidator(String? value) {
//     if (!widget.canBeEmpty && (value == null || value.isEmpty)) {
//       return widget.validationMessage ?? 'This field cannot be empty';
//     }
//
//     if (widget.minLength != null && value != null && value.length < widget.minLength!) {
//       return 'Minimum length is ${widget.minLength}';
//     }
//
//     if (widget.maxLength != null && value != null && value.length > widget.maxLength!) {
//       return 'Maximum length is ${widget.maxLength}';
//     }
//
//     if (widget.regexPattern != null && value != null && !RegExp(widget.regexPattern!).hasMatch(value)) {
//       return 'Invalid format';
//     }
//
//     if (widget.customValidators != null && widget.customValidators!.containsKey(widget.label)) {
//       return widget.customValidators![widget.label]!(value);
//     }
//
//     if (widget.keyboardType == TextInputType.number) {
//       if (value != null) {
//         final numValue = double.tryParse(value);
//         if (numValue == null || numValue.toStringAsFixed(3).length > value.length) {
//           return widget.validationMessage ?? 'Invalid number';
//         }
//       }
//     }
//
//     if (widget.label == Strings.amount && (value == '0' || value == '0.0')) {
//       return widget.validationMessage ?? 'Amount cannot be zero';
//     }
//
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<TextInputFormatter> inputFormatters = widget.keyboardType == TextInputType.number
//         ? [
//       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
//       TextInputFormatter.withFunction((oldValue, newValue) {
//         final text = newValue.text;
//         if (text.isEmpty) {
//           return newValue;
//         } else {
//           final numValue = double.tryParse(text);
//           if (numValue == null || RegExp(r'^\d*\.?\d{0,3}$').hasMatch(text)) {
//             return newValue;
//           } else {
//             return oldValue;
//           }
//         }
//       }),
//     ]
//         : widget.keyboardType == TextInputType.phone
//         ? [
//       FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
//       LengthLimitingTextInputFormatter(10),
//       CustomPhoneNumberFormatter()
//     ]
//         : [];
//
//     return Padding(
//       padding: const EdgeInsets.all(4),
//       child: TextFormField(
//         textDirection: widget.keyboardType == TextInputType.number || widget.keyboardType == TextInputType.phone
//             ? TextDirection.ltr
//             : TextDirection.rtl,
//         textAlign: TextAlign.right,
//         enabled: widget.enabled,
//         controller: widget.controller,
//         style: widget.textStyle,
//         decoration: InputDecoration(
//           labelText: widget.label,
//           suffixIcon: widget.suffixIcon != null ? Icon(widget.suffixIcon) : clearIcon(),
//         ),
//         readOnly: widget.readOnly ?? false,
//         onTap: widget.onTap,
//         onSaved: widget.onSaved,
//         validator: _generalValidator,
//         onChanged: widget.onChanged,
//         keyboardType: widget.keyboardType,
//         inputFormatters: inputFormatters,
//       ),
//     );
//   }
// }
//
// // Custom phone number formatter with Persian digit conversion
// class CustomPhoneNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     // Convert Persian digits to English
//     final englishText = convertPersianToEnglish(newValue.text);
//
//     // Remove non-digit characters
//     final digitsOnly = englishText.replaceAll(RegExp(r'\D'), '');
//     final length = digitsOnly.length;
//
//     String newText;
//     if (length <= 4) {
//       newText = digitsOnly;
//     } else if (length <= 7) {
//       newText = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
//     } else {
//       newText = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7, length)}';
//     }
//
//     return newValue.copyWith(
//       text: newText,
//       selection: TextSelection.collapsed(offset: newText.length),
//     );
//   }
// }
//
// // Function to convert Persian digits to English digits
// String convertPersianToEnglish(String input) {
//   const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
//   const englishDigits = '0123456789';
//
//   return input.split('').map((char) {
//     final index = persianDigits.indexOf(char);
//     return index == -1 ? char : englishDigits[index];
//   }).join('');
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool canBeEmpty;
  final int? minLength;
  final int? maxLength;
  final String? regexPattern;
  final Map<String, String Function(String?)>? customValidators;

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
    this.initialValue,
    this.canBeEmpty = true,
    this.minLength,
    this.maxLength,
    this.regexPattern,
    this.customValidators,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
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

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller?.text = widget.initialValue!;
    }
  }

  String? _generalValidator(String? value) {
    if (!widget.canBeEmpty && (value == null || value.isEmpty)) {
      return widget.validationMessage ?? 'This field cannot be empty';
      print('');
    }

    if (widget.minLength != null && value != null && value.length < widget.minLength!) {
      return 'Minimum length is ${widget.minLength}';
    }

    if (widget.maxLength != null && value != null && value.length > widget.maxLength!) {
      return 'Maximum length is ${widget.maxLength}';
    }

    if (widget.regexPattern != null && value != null && !RegExp(widget.regexPattern!).hasMatch(value)) {
      return 'Invalid format';
    }

    if (widget.customValidators != null && widget.customValidators!.containsKey(widget.label)) {
      return widget.customValidators![widget.label]!(value);
    }

    switch (widget.keyboardType) {
      case TextInputType.number:
        if (value != null && double.tryParse(value) == null) {
          return widget.validationMessage ?? 'Invalid number';
        }
        break;
      case TextInputType.phone:
        final digitsOnly = value!.replaceAll(RegExp(r'\D'), '');
        if(widget.canBeEmpty){
          return null;
        }
        if (digitsOnly.length != 10) {
          return widget.validationMessage ?? 'Invalid phone number';
        }
        break;
      case TextInputType.emailAddress:
        if (value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return widget.validationMessage ?? 'Invalid email address';
        }
        break;
      default:
        if (value == null || value.isEmpty) {
          return widget.validationMessage ?? 'This field cannot be empty';
        }
        break;
    }

    if (widget.label == Strings.amount && (value == '0' || value == '0.0')) {
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
      // FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
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
          suffixIcon:
          widget.suffixIcon != null ? Icon(widget.suffixIcon) : clearIcon(),
        ),
        readOnly: widget.readOnly ?? false,
        onTap: widget.onTap,
        onSaved: widget.onSaved,
        validator: _generalValidator,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}



// Custom phone number formatter with Persian digit conversion
class CustomPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Convert Persian digits to English
    final englishText = convertPersianToEnglish(newValue.text);

    // Remove non-digit characters
    final digitsOnly = englishText.replaceAll(RegExp(r'\D'), '');
    final length = digitsOnly.length;

    String newText;
    if (length <= 4) {
      newText = digitsOnly;
    } else if (length <= 7) {
      newText = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
    } else {
      newText =
      '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7, length)}';
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Function to convert Persian digits to English digits
String convertPersianToEnglish(String input) {
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  const englishDigits = '0123456789';

  return input.split('').map((char) {
    final index = persianDigits.indexOf(char);
    return index == -1 ? char : englishDigits[index];
  }).join('');
}


// import 'dart:ffi';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:ofoqe_naween/values/strings.dart';
//
// class CustomTextFormField extends StatefulWidget {
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;
//   final String? label, validationMessage, value, initialValue;
//   final IconData? suffixIcon;
//   final bool? readOnly, enabled;
//   final TextStyle? textStyle;
//   final VoidCallback? onTap;
//   final void Function(String?)? onSaved;
//   final void Function(String?)? onChanged;
//
//   const CustomTextFormField({
//     super.key,
//     this.controller,
//     required this.label,
//     this.readOnly,
//     this.onTap,
//     this.onChanged,
//     this.onSaved,
//     this.enabled,
//     this.validationMessage,
//     this.suffixIcon,
//     this.value,
//     this.keyboardType,
//     this.textStyle,
//     this.initialValue,
//   });
//
//   @override
//   State<CustomTextFormField> createState() => _CustomTextFormFieldState();
// }
//
// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   Widget clearIcon() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           widget.controller!.clear();
//         },
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (widget.initialValue != null) {
//       widget.controller?.text = widget.initialValue!;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<TextInputFormatter> inputFormatters =
//         widget.keyboardType == TextInputType.number
//             ? [
//                 FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
//                 TextInputFormatter.withFunction((oldValue, newValue) {
//                   final text = newValue.text;
//                   return text.isEmpty
//                       ? newValue
//                       : double.tryParse(text) == null
//                           ? oldValue
//                           : newValue;
//                 }),
//               ]
//             : widget.keyboardType == TextInputType.phone
//                 ? [
//                     FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
//                     LengthLimitingTextInputFormatter(10),
//                     CustomPhoneNumberFormatter()
//                   ]
//                 : [];
//
//     return Padding(
//       padding: const EdgeInsets.all(4),
//       child: TextFormField(
//         // initialValue: widget.initialValue,
//         textDirection: widget.keyboardType == TextInputType.number ||
//                 widget.keyboardType == TextInputType.phone
//             ? TextDirection.ltr
//             : TextDirection.rtl,
//         textAlign: TextAlign.right,
//         enabled: widget.enabled,
//         controller: widget.controller,
//         style: widget.textStyle,
//         decoration: InputDecoration(
//           labelText: widget.label,
//           suffixIcon:
//               widget.suffixIcon != null ? Icon(widget.suffixIcon) : clearIcon(),
//         ),
//         readOnly: widget.readOnly ?? false,
//         onTap: widget.onTap,
//         onSaved: widget.onSaved,
//         validator: (value) {
//           if (widget.keyboardType == TextInputType.number ||
//               widget.keyboardType == TextInputType.phone) {
//             final digitsOnly = value!.replaceAll(RegExp(r'\D'), '');
//             if (digitsOnly.isEmpty) {
//               print('digits only');
//               if (widget.keyboardType == TextInputType.number) {
//                 return widget.validationMessage;
//               }
//               return null;
//             } else if (digitsOnly.length != 10 &&
//                 widget.keyboardType == TextInputType.phone) {
//               print('phone only');
//               return widget.validationMessage;
//             } else if (widget.label == Strings.amount &&
//                 (value == '0' || value == '0.0')) {
//               return widget.validationMessage;
//             } else {
//               return null;
//             }
//           }
//           // Email validation
//           if (widget.keyboardType == TextInputType.emailAddress) {
//             if (value!.isEmpty) {
//               return null;
//             } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                 .hasMatch(value)) {
//               return widget.validationMessage;
//             }
//           }
//
//           if (value == null || value.isEmpty) {
//             return widget.validationMessage;
//           }
//
//           return null;
//         },
//         onChanged: widget.onChanged,
//         keyboardType: widget.keyboardType,
//         inputFormatters: inputFormatters,
//       ),
//     );
//   }
// }
//
// // Custom phone number formatter with Persian digit conversion
// class CustomPhoneNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     // Convert Persian digits to English
//     final englishText = convertPersianToEnglish(newValue.text);
//
//     // Remove non-digit characters
//     final digitsOnly = englishText.replaceAll(RegExp(r'\D'), '');
//     final length = digitsOnly.length;
//
//     String newText;
//     if (length <= 4) {
//       newText = digitsOnly;
//     } else if (length <= 7) {
//       newText = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
//     } else {
//       newText =
//           '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7, length)}';
//     }
//
//     return newValue.copyWith(
//       text: newText,
//       selection: TextSelection.collapsed(offset: newText.length),
//     );
//   }
// }
//
// // Function to convert Persian digits to English digits
// String convertPersianToEnglish(String input) {
//   const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
//   const englishDigits = '0123456789';
//
//   return input.split('').map((char) {
//     final index = persianDigits.indexOf(char);
//     return index == -1 ? char : englishDigits[index];
//   }).join('');
// }
