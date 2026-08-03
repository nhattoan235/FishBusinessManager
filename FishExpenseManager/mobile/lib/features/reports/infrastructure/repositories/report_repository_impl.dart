import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase _db;

  ReportRepositoryImpl(this._db);

  @override
  Future<List<MonthlyStatEntity>> getMonthlyStats(int year) async {
    final start = DateTime(year, 1, 1);
    final endExclusive = DateTime(year + 1, 1, 1);
    final transactions = await (_db.select(_db.transactions)
          ..where((row) =>
              row.date.isBiggerOrEqualValue(start) &
              row.date.isSmallerThanValue(endExclusive)))
        .get();

    final incomeByMonth = List<double>.filled(12, 0);
    final expenseByMonth = List<double>.filled(12, 0);
    for (final transaction in transactions) {
      final localDate = transaction.date.toLocal();
      final index = localDate.month - 1;
      if (transaction.isIncome) {
        incomeByMonth[index] += transaction.amount;
      } else {
        expenseByMonth[index] += transaction.amount;
      }
    }

    return List.generate(
      12,
      (index) => MonthlyStatEntity(
        year: year,
        month: index + 1,
        totalIncome: incomeByMonth[index],
        totalExpense: expenseByMonth[index],
      ),
    );
  }

  @override
  Future<List<DailyStatEntity>> getDailyStats(int year, int month) async {
    final start = DateTime(year, month, 1);
    final endExclusive = DateTime(year, month + 1, 1);
    final transactions = await (_db.select(_db.transactions)
          ..where((row) =>
              row.date.isBiggerOrEqualValue(start) &
              row.date.isSmallerThanValue(endExclusive)))
        .get();

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final incomeByDay = List<double>.filled(daysInMonth, 0);
    final expenseByDay = List<double>.filled(daysInMonth, 0);
    for (final transaction in transactions) {
      final localDate = transaction.date.toLocal();
      final index = localDate.day - 1;
      if (transaction.isIncome) {
        incomeByDay[index] += transaction.amount;
      } else {
        expenseByDay[index] += transaction.amount;
      }
    }

    return List.generate(
      daysInMonth,
      (index) => DailyStatEntity(
        date: DateTime(year, month, index + 1),
        income: incomeByDay[index],
        expense: expenseByDay[index],
      ),
    );
  }

  @override
  Future<Map<String, double>> getProfitSummary() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final startOfSixMonths = DateTime(now.year, now.month - 5, 1);

    final transactions = await (_db.select(_db.transactions)
          ..where((row) =>
              row.date.isBiggerOrEqualValue(startOfSixMonths) &
              row.date.isSmallerThanValue(nextMonth)))
        .get();

    var monthIncome = 0.0;
    var monthExpense = 0.0;
    var sixMonthIncome = 0.0;
    var sixMonthExpense = 0.0;
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        sixMonthIncome += transaction.amount;
        if (!transaction.date.isBefore(startOfMonth)) {
          monthIncome += transaction.amount;
        }
      } else {
        sixMonthExpense += transaction.amount;
        if (!transaction.date.isBefore(startOfMonth)) {
          monthExpense += transaction.amount;
        }
      }
    }

    return {
      'monthProfit': monthIncome - monthExpense,
      'quarterProfit': sixMonthIncome - sixMonthExpense,
    };
  }
}
