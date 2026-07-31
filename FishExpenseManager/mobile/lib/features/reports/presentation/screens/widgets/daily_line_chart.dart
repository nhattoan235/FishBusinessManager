import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/report_entity.dart';

/// Biểu đồ đường (Line Chart) thu chi theo ngày trong tháng
class DailyLineChart extends StatelessWidget {
  final List<DailyStatEntity> stats;

  const DailyLineChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final hasData = stats.any((d) => d.income > 0 || d.expense > 0);

    if (!hasData) {
      return const Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          // Income line
          LineChartBarData(
            spots: stats.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.income)).toList(),
            isCurved: true,
            color: AppColors.success,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withAlpha(30),
            ),
          ),
          // Expense line
          LineChartBarData(
            spots: stats.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.expense)).toList(),
            isCurved: true,
            color: AppColors.error,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.error.withAlpha(20),
            ),
          ),
        ],
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
              interval: 4,
              getTitlesWidget: (value, meta) {
                final day = value.toInt() + 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$day',
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItems: (spots) => spots.map((spot) {
              final isIncome = spot.barIndex == 0;
              return LineTooltipItem(
                '${isIncome ? '↓' : '↑'} ${CurrencyFormatter.format(spot.y)}',
                TextStyle(
                  color: isIncome ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
