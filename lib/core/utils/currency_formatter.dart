import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Format ke Rupiah (contoh: Rp 125.000)
  static String format(double amount) {
    return _formatter.format(amount);
  }

  // Format compact (contoh: 1,2 Jt)
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }

  // Parse dari string ke double
  static double parse(String text) {
    // Hapus semua karakter non-numeric
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanText) ?? 0;
  }

  // Format saat input (real-time)
  static String formatInput(String value) {
    if (value.isEmpty) return '';

    final number = parse(value);
    if (number == 0) return '';

    return NumberFormat('#,###', 'id_ID').format(number);
  }

  // Format dengan tanda + atau -
  static String formatWithSign(double amount) {
    final formatted = format(amount.abs());
    return amount >= 0 ? '+ $formatted' : '- $formatted';
  }
}