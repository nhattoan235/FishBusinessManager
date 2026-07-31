import '../entities/report_entity.dart';

abstract class ReportRepository {
  /// Trả về thống kê theo từng tháng trong năm [year]
  Future<List<MonthlyStatEntity>> getMonthlyStats(int year);
  
  /// Trả về thống kê theo từng ngày trong tháng [month] năm [year]
  Future<List<DailyStatEntity>> getDailyStats(int year, int month);

  /// Trả về Lãi trong tháng hiện tại và quý (6 tháng)
  Future<Map<String, double>> getProfitSummary();
}
