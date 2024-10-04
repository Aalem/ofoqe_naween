import 'package:flutter/material.dart';

class DateWithSuffix extends StatelessWidget {
  final String date;
  final String suffix;
  final Color? dateColor;

  const DateWithSuffix({
    Key? key,
    required this.date,
    required this.suffix,
    this.dateColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date as needed
    // final formattedDate = "${date.day}/${date.month}/${date.year}"; // Adjust formatting as needed

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: date,
            style: TextStyle(
              // fontSize: 16, // Normal text size
              color: dateColor  , // Normal text color
            ),
          ),
          TextSpan(
            text: ' $suffix', // Add space before suffix
            style: TextStyle(
              fontSize: 12, // Same size as normal text
              color: Colors.grey, // Grey color for suffix
            ),
          ),
        ],
      ),
    );
  }
}
