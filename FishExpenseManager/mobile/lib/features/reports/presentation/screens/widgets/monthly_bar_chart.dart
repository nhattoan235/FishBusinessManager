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
    // Only show months that have data OR all 12 months
    final activeStats = stats.length > 12 ? stats.sublist(0, 12) : stats;

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
                width: 6,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
              BarChartRodData(
                toY: stat.totalExpense,
                color: AppColors.error,
                width: 6,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  CurrencyFormatter.formatCompact(value),
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
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
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'T${activeStats[idx].month}',
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
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
