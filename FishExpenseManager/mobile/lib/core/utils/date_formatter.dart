import 'package:intl/intl.dart';

abstract class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Định dạng ngày (dd/MM/yyyy)
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime.toLocal());
  }

  /// Định dạng giờ (HH:mm)
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime.toLocal());
  }

  /// Định dạng cả ngày và giờ (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  /// Kiểm tra ngày có phải là hôm nay không
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }
}
