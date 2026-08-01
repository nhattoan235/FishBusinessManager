import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase _db;

  DashboardRepositoryImpl(this._db);

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    // 1. Total Cash: Sum(income) - Sum(expense) from transactions
    final cashResult = await _db
        .customSelect(
          'SELECT SUM(CASE WHEN is_income = 1 THEN amount ELSE -amount END) AS total FROM transactions',
        )
        .getSingle();
    final totalCashRaw = cashResult.data['total'];
    final totalCash =
        (totalCashRaw != null) ? (totalCashRaw as num).toDouble() : 0.0;

    // 2. Today Income & Expense
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
    final todayResult = await _db.customSelect(
      '''
      SELECT 
        SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) AS income,
        SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) AS expense
      FROM transactions 
      WHERE date >= ?
      ''',
      variables: [Variable.withInt(startOfDay)],
    ).getSingle();
    final todayIncomeRaw = todayResult.data['income'];
    final todayExpenseRaw = todayResult.data['expense'];
    final todayIncome =
        (todayIncomeRaw != null) ? (todayIncomeRaw as num).toDouble() : 0.0;
    final todayExpense =
        (todayExpenseRaw != null) ? (todayExpenseRaw as num).toDouble() : 0.0;

    // 3. Total Receivables: Sum of CustomerBalances (current_debt column)
    final debtResult = await _db
        .customSelect(
            'SELECT SUM(current_debt) AS total FROM customer_balances WHERE current_debt > 0')
        .getSingle();
    final debtRaw = debtResult.data['total'];
    final totalReceivables =
        (debtRaw != null) ? (debtRaw as num).toDouble() : 0.0;

    // 4. Total Inventory: Sum of quantity in InventoryEntries (Ledger: negative for sales)
    final invResult = await _db
        .customSelect('SELECT SUM(quantity) AS total FROM inventory_entries')
        .getSingle();
    final invRaw = invResult.data['total'];
    final totalInventory = (invRaw != null) ? (invRaw as num).toDouble() : 0.0;

    return DashboardSummary(
      totalCash: totalCash,
      todayIncome: todayIncome,
      todayExpense: todayExpense,
      totalReceivables: totalReceivables,
      totalInventory: totalInventory.clamp(0, double.infinity),
    );
  }

  @override
  Stream<DashboardSummary> watchDashboardSummary() {
    // Use a periodic refresh approach since customSelect doesn't support reactive streams easily
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => getDashboardSummary())
        .distinct();
  }
}
