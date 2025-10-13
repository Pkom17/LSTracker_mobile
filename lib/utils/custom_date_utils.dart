import 'package:intl/intl.dart';

class CustomDateUtils {
  /// Converts a date string to a human-readable format.
  static String? toHumanReadable(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    // On s'assure que la chaîne a au moins 16 caractères avant de la découper.
    final String parsedString = dateString.length >= 16
        ? dateString.substring(0, 16)
        : dateString;

    try {
      final DateTime dateTime = DateTime.parse(parsedString);

      final DateFormat formatter = DateFormat('dd/MM/yyyy à HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      try {
        final String isoFormatted = parsedString.replaceFirst(' ', 'T');
        final DateTime dateTime = DateTime.parse(isoFormatted);

        final DateFormat formatter = DateFormat('dd/MM/yyyy à HH:mm');
        return formatter.format(dateTime);
      } catch (e2) {
        return null;
      }
    }
  }
}
