import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/report_entity.dart';

/// Biểu đồ cột (Bar Chart) thu chi theo ngày trong tháng (7 ngày)
class DailyBarChart extends StatelessWidget {
  final List<DailyStatEntity> stats;
  final bool isIncome;

  const DailyBarChart({super.key, required this.stats, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    // Chỉ lấy 7 ngày gần nhất tính từ ngày có dữ liệu cuối cùng, hoặc 7 ngày cuối tháng nếu không có
    // Do stats đã được sort theo ngày từ mùng 1 -> cuối tháng
    
    // Tìm ngày cuối cùng có dữ liệu
    int lastDataIndex = stats.lastIndexWhere((d) => d.income > 0 || d.expense > 0);
    
    List<DailyStatEntity> chartStats;
    if (lastDataIndex == -1) {
      // Không có dữ liệu, lấy 7 ngày đầu hoặc cuối tùy ý, ở đây lấy 7 ngày cuối tháng
      chartStats = stats.length > 7 ? stats.sublist(stats.length - 7) : stats;
    } else {
      // Lấy 7 ngày kết thúc tại lastDataIndex (nếu đủ)
      int startIndex = lastDataIndex >= 6 ? lastDataIndex - 6 : 0;
      chartStats = stats.sublist(startIndex, lastDataIndex + 1);
    }

    final hasData = chartStats.any((d) => isIncome ? d.income > 0 : d.expense > 0);
    final color = isIncome ? AppColors.success : AppColors.error;

    if (!hasData) {
      return Center(
        child: Text(isIncome ? 'Không có thu' : 'Không có chi', style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${isIncome ? 'Thu' : 'Chi'}: ${CurrencyFormatter.format(rod.toY)}',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartStats.length) return const SizedBox.shrink();
                final stat = chartStats[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ngày ${stat.date.day}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        barGroups: chartStats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final value = isIncome ? stat.income : stat.expense;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: color,
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
