import 'package:flutter/material.dart';
import 'package:ofoqe_naween/values/strings.dart';

class NothingFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.search_off,
          size: 100,
          color: Colors.orange,
        ),
        const SizedBox(height: 20),
        const Text(
          Strings.nothingFound,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          Strings.nothingFoundGuide,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
