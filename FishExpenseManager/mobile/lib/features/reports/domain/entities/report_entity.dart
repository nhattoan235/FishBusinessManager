/// Dữ liệu thống kê cho một tháng
class MonthlyStatEntity {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double profit; // lãi/lỗ = income - expense

  const MonthlyStatEntity({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
  }) : profit = totalIncome - totalExpense;

  String get monthLabel => '$month/${year.toString().substring(2)}';
}

/// Dữ liệu thống kê theo ngày trong tháng (cho biểu đồ line)
class DailyStatEntity {
  final DateTime date;
  final double income;
  final double expense;

  const DailyStatEntity({
    required this.date,
    required this.income,
    required this.expense,
  });
}

/// Thống kê tổng hợp cho khoảng thời gian
class ReportSummaryEntity {
  final double totalIncome;
  final double totalExpense;
  final double profit;
  final int transactionCount;
  final List<MonthlyStatEntity> monthlyStats;

  const ReportSummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.transactionCount,
    required this.monthlyStats,
  });
}
