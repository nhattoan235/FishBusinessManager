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
final monthlyStatsProvider = FutureProvider<List<MonthlyStatEntity>>((ref) {
  final year = ref.watch(selectedYearProvider);
  return ref.watch(reportRepositoryProvider).getMonthlyStats(year);
});

/// Provider thống kê ngày trong tháng
final dailyStatsProvider = FutureProvider<List<DailyStatEntity>>((ref) {
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(reportRepositoryProvider).getDailyStats(year, month);
});

/// Provider tổng kết Lãi tháng và quý
final profitSummaryProvider = FutureProvider<Map<String, double>>((ref) {
  // Watch year/month so it refreshes when user changes time, though it always computes from 'now' in repository.
  // Actually, to make it react to transactions, we might need to invalidate it on sale. 
  // For now, it's fetched once when screen opens.
  return ref.watch(reportRepositoryProvider).getProfitSummary();
});
