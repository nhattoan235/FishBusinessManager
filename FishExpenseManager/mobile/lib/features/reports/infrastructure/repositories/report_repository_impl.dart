import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase _db;

  ReportRepositoryImpl(this._db);

  @override
  Future<List<MonthlyStatEntity>> getMonthlyStats(int year) async {
    if (kIsWeb) {
      // Mock data: 6 months of demo data
      return List.generate(6, (i) {
        final month = i + 1;
        return MonthlyStatEntity(
          year: year,
          month: month,
          totalIncome: (5000000 + i * 800000).toDouble(),
          totalExpense: (2000000 + i * 300000).toDouble(),
        );
      });
    }

    // Build start/end of year Unix timestamps
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

    final startTs = startOfYear.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfYear.millisecondsSinceEpoch ~/ 1000;

    final result = await _db.customSelect(
      '''
      SELECT 
        strftime('%m', datetime(date, 'unixepoch')) AS month,
        SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) AS total_expense
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY month
      ORDER BY month
      ''',
      variables: [Variable.withInt(startTs), Variable.withInt(endTs)],
    ).get();

    // Build all 12 months, filling with 0 for months with no data
    final Map<int, MonthlyStatEntity> monthMap = {};
    for (final row in result) {
      final monthStr = row.data['month'] as String;
      final month = int.parse(monthStr);
      final income = (row.data['total_income'] as num?)?.toDouble() ?? 0.0;
      final expense = (row.data['total_expense'] as num?)?.toDouble() ?? 0.0;
      monthMap[month] = MonthlyStatEntity(
        year: year,
        month: month,
        totalIncome: income,
        totalExpense: expense,
      );
    }

    // Fill all months
    return List.generate(12, (i) {
      final month = i + 1;
      return monthMap[month] ?? MonthlyStatEntity(
        year: year,
        month: month,
        totalIncome: 0,
        totalExpense: 0,
      );
    });
  }

  @override
  Future<List<DailyStatEntity>> getDailyStats(int year, int month) async {
    if (kIsWeb) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      return List.generate(daysInMonth, (i) {
        final day = i + 1;
        return DailyStatEntity(
          date: DateTime(year, month, day),
          income: day % 3 == 0 ? 1500000 : 0,
          expense: day % 5 == 0 ? 500000 : 0,
        );
      });
    }

    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final startTs = startOfMonth.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfMonth.millisecondsSinceEpoch ~/ 1000;

    final result = await _db.customSelect(
      '''
      SELECT 
        strftime('%d', datetime(date, 'unixepoch')) AS day,
        SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) AS total_expense
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY day
      ORDER BY day
      ''',
      variables: [Variable.withInt(startTs), Variable.withInt(endTs)],
    ).get();

    final Map<int, DailyStatEntity> dayMap = {};
    for (final row in result) {
      final dayStr = row.data['day'] as String;
      final day = int.parse(dayStr);
      final income = (row.data['total_income'] as num?)?.toDouble() ?? 0.0;
      final expense = (row.data['total_expense'] as num?)?.toDouble() ?? 0.0;
      dayMap[day] = DailyStatEntity(
        date: DateTime(year, month, day),
        income: income,
        expense: expense,
      );
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final day = i + 1;
      return dayMap[day] ?? DailyStatEntity(
        date: DateTime(year, month, day),
        income: 0,
        expense: 0,
      );
    });
  }
}
