import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  /// Định dạng số tiền thành chuỗi hiển thị. Ví dụ: 15200000 -> "15.200.000 đ"
  static String format(num amount) {
    return _formatter.format(amount).trim();
  }

  /// Định dạng kèm dấu + hoặc -. Ví dụ: +2.500.000 đ, -800.000 đ
  static String formatWithSign(num amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    final absAmount = amount.abs();
    return '$prefix${format(absAmount)}';
  }
}
