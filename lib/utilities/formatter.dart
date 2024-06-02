import 'package:intl/intl.dart' as intl;

class GeneralFormatter {
  static final intl.NumberFormat numberFormat = intl.NumberFormat('###,##0.00', 'en_US');

  static String formatNumber(String value) {
    try {
      final double number = double.parse(value.replaceAll(',', ''));
      return numberFormat.format(number);
    } catch (e) {
      print('Error formatting number: $e');
      return value;
    }
  }

  static String formatDate(String value, {String pattern = 'yyyy-MM-dd'}) {
    try {
      final date = DateTime.parse(value);
      final dateFormat = intl.DateFormat(pattern);
      return dateFormat.format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return value;
    }
  }

  static String formatPhoneNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final length = digitsOnly.length;

    String formattedNumber;
    if (length <= 4) {
      formattedNumber = digitsOnly;
    } else if (length <= 7) {
      formattedNumber = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
    } else {
      formattedNumber = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
    }

    return formattedNumber;
  }

  static String formatAndRemoveTrailingZeros(dynamic value) {
    try {
      // Convert input to a double
      final double number = value is String ? double.parse(value.replaceAll(',', '')) : value.toDouble();

      // If the number is 0, return an empty string
      if (number == 0) {
        return '';
      }

      // Format the number
      String formattedNumber = numberFormat.format(number);

      // Remove trailing zeros
      if (formattedNumber.contains('.')) {
        formattedNumber = formattedNumber.replaceAll(RegExp(r'0*$'), ''); // Remove trailing decimal zeros
        formattedNumber = formattedNumber.replaceAll(RegExp(r'\.$'), ''); // Remove trailing decimal point if it's the last character
      } else {
        formattedNumber = formattedNumber.replaceAll(RegExp(r'\.0*$'), ''); // Remove trailing zeros
      }

      return formattedNumber;
    } catch (e) {
      print('Error formatting and removing trailing zeros: $e');
      return value.toString(); // Return the original value if an error occurs
    }
  }


}