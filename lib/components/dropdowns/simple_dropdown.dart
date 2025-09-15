import 'package:flutter/material.dart';

class SimpleDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final String? selectedValue;
  final String Function(T) getLabel;
  final String Function(T) getValue;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const SimpleDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.getLabel,
    required this.getValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: getValue(item),
            child: Text(getLabel(item)),
          );
        }).toList(),
        value: selectedValue,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
