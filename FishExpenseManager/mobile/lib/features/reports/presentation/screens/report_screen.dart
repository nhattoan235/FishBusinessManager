import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/report_provider.dart';
import '../../domain/entities/report_entity.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/daily_line_chart.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(selectedYearProvider);
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Theo tháng', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Theo ngày', icon: Icon(Icons.show_chart)),
          ],
        ),
        actions: [
          // Year selector
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text('$year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () => _pickYear(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthlyTab(year: year),
          _DailyTab(year: year, month: month),
        ],
      ),
    );
  }

  Future<void> _pickYear(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn năm'),
        children: years.map((y) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, y),
          child: Text('$y', style: const TextStyle(fontSize: 18)),
        )).toList(),
      ),
    );
    if (selected != null) {
      ref.read(selectedYearProvider.notifier).state = selected;
    }
  }
}

// ─── Monthly Tab ─────────────────────────────────────────────────────────────

class _MonthlyTab extends ConsumerWidget {
  final int year;
  const _MonthlyTab({required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthlyStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final totalIncome = stats.fold<double>(0, (sum, s) => sum + s.totalIncome);
        final totalExpense = stats.fold<double>(0, (sum, s) => sum + s.totalExpense);
        final profit = totalIncome - totalExpense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary cards
              Row(
                children: [
                  _SummaryCard(
                    label: 'Tổng thu',
                    amount: totalIncome,
                    color: AppColors.success,
                    icon: Icons.arrow_downward,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _SummaryCard(
                    label: 'Tổng chi',
                    amount: totalExpense,
                    color: AppColors.error,
                    icon: Icons.arrow_upward,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProfitCard(profit: profit),
              const SizedBox(height: AppSpacing.lg),

              // Bar chart
              const Text(
                'Biểu đồ thu chi theo tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    height: 220,
                    child: MonthlyBarChart(stats: stats),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Monthly detail list
              const Text(
                'Chi tiết từng tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...stats.where((s) => s.totalIncome > 0 || s.totalExpense > 0).map(
                (s) => _MonthlyRow(stat: s),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err')),
    );
  }
}

// ─── Daily Tab ───────────────────────────────────────────────────────────────

class _DailyTab extends ConsumerWidget {
  final int year;
  final int month;
  const _DailyTab({required this.year, required this.month});

  static const _months = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dailyStatsProvider);

    return Column(
      children: [
        // Month selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: month > 1
                    ? () => ref.read(selectedMonthProvider.notifier).state = month - 1
                    : null,
              ),
              Expanded(
                child: Text(
                  _months[month],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: month < 12
                    ? () => ref.read(selectedMonthProvider.notifier).state = month + 1
                    : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: statsAsync.when(
            data: (stats) {
              final totalIncome = stats.fold<double>(0, (s, d) => s + d.income);
              final totalExpense = stats.fold<double>(0, (s, d) => s + d.expense);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _SummaryCard(
                          label: 'Thu tháng',
                          amount: totalIncome,
                          color: AppColors.success,
                          icon: Icons.arrow_downward,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _SummaryCard(
                          label: 'Chi tháng',
                          amount: totalExpense,
                          color: AppColors.error,
                          icon: Icons.arrow_upward,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          height: 200,
                          child: DailyLineChart(stats: stats),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Only show days with data
                    ...stats.where((d) => d.income > 0 || d.expense > 0).map(
                      (d) => _DailyRow(stat: d),
                    ),
                    if (stats.every((d) => d.income == 0 && d.expense == 0))
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('Không có dữ liệu trong tháng này')),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 4),
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final double profit;
  const _ProfitCard({required this.profit});

  @override
  Widget build(BuildContext context) {
    final isProfit = profit >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;
    final label = isProfit ? 'Lãi trong năm' : 'Lỗ trong năm';

    return Card(
      color: color.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: color, size: 28),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                Text(
                  CurrencyFormatter.format(profit.abs()),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final MonthlyStatEntity stat;
  const _MonthlyRow({required this.stat});

  static const _monthNames = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    final isProfit = stat.profit >= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_monthNames[stat.month],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            Row(
              children: [
                _StatChip(label: '↓ Thu', amount: stat.totalIncome, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(label: '↑ Chi', amount: stat.totalExpense, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: isProfit ? 'Lãi' : 'Lỗ',
                  amount: stat.profit.abs(),
                  color: isProfit ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _StatChip({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyStatEntity stat;
  const _DailyRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            '${stat.date.day}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        title: Row(
          children: [
            if (stat.income > 0)
              Text('+ ${CurrencyFormatter.formatCompact(stat.income)}',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
            if (stat.income > 0 && stat.expense > 0) const SizedBox(width: AppSpacing.sm),
            if (stat.expense > 0)
              Text('- ${CurrencyFormatter.formatCompact(stat.expense)}',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
