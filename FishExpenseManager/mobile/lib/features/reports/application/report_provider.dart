import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/entities/report_entity.dart';
import '../domain/repositories/report_repository.dart';
import '../infrastructure/repositories/report_repository_impl.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportRepositoryImpl(db);
});

/// Provider cho năm được chọn (mặc định năm hiện tại)
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

/// Provider cho tháng được chọn (mặc định tháng hiện tại)
final selectedMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

/// Provider thống kê tháng trong năm
final monthlyStatsProvider =
    StreamProvider.autoDispose<List<MonthlyStatEntity>>((ref) {
  final year = ref.watch(selectedYearProvider);
  final db = ref.watch(databaseProvider);
  final repository = ref.watch(reportRepositoryProvider);
  return db
      .customSelect(
        'SELECT COUNT(*) AS transaction_count FROM transactions',
        readsFrom: {db.transactions},
      )
      .watch()
      .asyncMap((_) => repository.getMonthlyStats(year));
});

/// Provider thống kê ngày trong tháng
final dailyStatsProvider =
    StreamProvider.autoDispose<List<DailyStatEntity>>((ref) {
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);
  final db = ref.watch(databaseProvider);
  final repository = ref.watch(reportRepositoryProvider);
  return db
      .customSelect(
        'SELECT COUNT(*) AS transaction_count FROM transactions',
        readsFrom: {db.transactions},
      )
      .watch()
      .asyncMap((_) => repository.getDailyStats(year, month));
});

/// Provider tổng kết Lãi tháng và quý
final profitSummaryProvider =
    StreamProvider.autoDispose<Map<String, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final repository = ref.watch(reportRepositoryProvider);
  return db
      .customSelect(
        'SELECT COUNT(*) AS transaction_count FROM transactions',
        readsFrom: {db.transactions},
      )
      .watch()
      .asyncMap((_) => repository.getProfitSummary());
});
