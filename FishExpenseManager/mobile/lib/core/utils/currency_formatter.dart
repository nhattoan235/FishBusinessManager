import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  /// Định dạng số tiền thành chuỗi hiển thị. Ví dụ: 15200000 -> "15.200.000 đ"
  static String format(num amount) {
    // Ép buộc dùng dấu '.' làm phân cách hàng ngàn thay vì ','
    String formatted = _formatter.format(amount).trim();
    // Thay thế ',' thành '.' nếu locale vi_VN không được load đúng
    // Nhưng vì symbol 'đ' có thể có, ta nên cẩn thận.
    // Thực tế vi_VN mặc định dùng '.' cho hàng ngàn, 
    // nhưng trên Web đôi khi bị lỗi fallback về ','.
    formatted = formatted.replaceAll(',', '.');
    return formatted;
  }

  /// Định dạng kèm dấu + hoặc -. Ví dụ: +2.500.000 đ, -800.000 đ
  static String formatWithSign(num amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    final absAmount = amount.abs();
    return '$prefix${format(absAmount)}';
  }

  /// Định dạng ngắn gọn cho biểu đồ. Ví dụ: 1.500.000 -> "1.5tr", 500.000 -> "500k"
  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
