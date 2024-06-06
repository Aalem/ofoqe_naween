
import 'package:dari_datetime_picker/dari_datetime_picker.dart';

class DateTimeUtils {

  /// Converts a Jalali date string (formatted as yyyy/MM/dd) to a Jalali object.
  static Jalali stringToJalaliDate(String date) {
    List<String> parts = date.split('/');
    if (parts.length != 3) {
      throw FormatException("Invalid Jalali date format. Expected yyyy/MM/dd.");
    }

    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    return Jalali(year, month, day);
  }
}
