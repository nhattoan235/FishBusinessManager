class DashboardSummary {
  final double totalCash;
  final double todayIncome;
  final double todayExpense;
  final double totalReceivables;
  final double totalInventory;

  const DashboardSummary({
    required this.totalCash,
    required this.todayIncome,
    required this.todayExpense,
    required this.totalReceivables,
    required this.totalInventory,
  });

  factory DashboardSummary.empty() => const DashboardSummary(
        totalCash: 0,
        todayIncome: 0,
        todayExpense: 0,
        totalReceivables: 0,
        totalInventory: 0,
      );
}
