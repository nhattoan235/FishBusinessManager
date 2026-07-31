import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../infrastructure/repositories/dashboard_repository_impl.dart';
import '../domain/entities/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepositoryImpl(db);
});

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardSummary();
});
