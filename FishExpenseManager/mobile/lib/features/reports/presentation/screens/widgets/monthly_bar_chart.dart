import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/report_entity.dart';

/// Biểu đồ thanh (Bar Chart) so sánh Thu vs Chi theo từng tháng
class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStatEntity> stats;

  const MonthlyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Chỉ lấy 3 tháng gần nhất có dữ liệu (hoặc 3 tháng cuối nếu không có dữ liệu)
    final monthsWithData = stats.where((s) => s.totalIncome > 0 || s.totalExpense > 0).toList();
    List<MonthlyStatEntity> activeStats;
    if (monthsWithData.isEmpty) {
      activeStats = stats.length >= 3 ? stats.sublist(stats.length - 3) : stats;
    } else {
      activeStats = monthsWithData.length > 3 
          ? monthsWithData.sublist(monthsWithData.length - 3) 
          : monthsWithData;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _maxY(activeStats) * 1.2,
        barGroups: activeStats.asMap().entries.map((e) {
          final index = e.key;
          final stat = e.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: stat.totalIncome,
                color: AppColors.success,
                width: 24, // Cột to hơn
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: stat.totalExpense,
                color: AppColors.error,
                width: 24, // Cột to hơn
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
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
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= activeStats.length) return const SizedBox.shrink();
                final month = activeStats[idx].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tháng $month',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (val) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isIncome = rodIndex == 0;
              return BarTooltipItem(
                '${isIncome ? '↓ Thu' : '↑ Chi'}\n${CurrencyFormatter.format(rod.toY)}',
                TextStyle(
                  color: isIncome ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _maxY(List<MonthlyStatEntity> stats) {
    double max = 0;
    for (final s in stats) {
      if (s.totalIncome > max) max = s.totalIncome;
      if (s.totalExpense > max) max = s.totalExpense;
    }
    return max == 0 ? 1000000 : max;
  }
}
