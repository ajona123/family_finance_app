import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    }
    return format(amount);
  }

  static double parse(String text) {
    // Remove all non-numeric characters except dot
    String cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static String formatInput(String text) {
    if (text.isEmpty) return '';
    double? value = double.tryParse(text.replaceAll(RegExp(r'[^\d]'), ''));
    if (value == null) return text;

    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }
}