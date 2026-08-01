import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/report_provider.dart';
import '../../domain/entities/report_entity.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/daily_bar_chart.dart';

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
    // initialIndex: 1 => Tab Theo ngày
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
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
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.white,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          indicatorColor: Colors.yellow,
          indicatorWeight: 4,
          tabs: const [
            Tab(text: 'Theo tháng', icon: Icon(Icons.bar_chart, size: 28)),
            Tab(text: 'Theo ngày', icon: Icon(Icons.show_chart, size: 28)),
          ],
        ),
        actions: [
          // Year selector
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text('$year',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        children: years
            .map((y) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, y),
                  child: Text('$y', style: const TextStyle(fontSize: 18)),
                ))
            .toList(),
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
        final totalIncome =
            stats.fold<double>(0, (sum, s) => sum + s.totalIncome);
        final totalExpense =
            stats.fold<double>(0, (sum, s) => sum + s.totalExpense);

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
              const _ProfitSummaryCard(),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...stats
                  .where((s) => s.totalIncome > 0 || s.totalExpense > 0)
                  .map(
                    (s) => _MonthlyRow(stat: s, year: year),
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
    '',
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dailyStatsProvider);

    return Column(
      children: [
        // Month selector
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: month > 1
                    ? () => ref.read(selectedMonthProvider.notifier).state =
                        month - 1
                    : null,
              ),
              Expanded(
                child: Text(
                  '${_months[month]} / $year',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: month < 12
                    ? () => ref.read(selectedMonthProvider.notifier).state =
                        month + 1
                    : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: statsAsync.when(
            data: (stats) {
              final totalIncome = stats.fold<double>(0, (s, d) => s + d.income);
              final totalExpense =
                  stats.fold<double>(0, (s, d) => s + d.expense);

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

                    const Text(
                      'Biểu đồ Tổng Thu (7 ngày)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          height: 200,
                          child: DailyBarChart(stats: stats, isIncome: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    const Text(
                      'Biểu đồ Tổng Chi (7 ngày)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          height: 200,
                          child: DailyBarChart(stats: stats, isIncome: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    const Text(
                      'Chi tiết từng ngày',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Only show days with data
                    ...stats.where((d) => d.income > 0 || d.expense > 0).map(
                          (d) => _DailyRow(stat: d),
                        ),
                    if (stats.every((d) => d.income == 0 && d.expense == 0))
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                            child: Text('Không có dữ liệu trong tháng này')),
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
                  Text(label,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w600)),
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

class _ProfitSummaryCard extends ConsumerWidget {
  const _ProfitSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(profitSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final mProfit = summary['monthProfit'] ?? 0;
        final qProfit = summary['quarterProfit'] ?? 0;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9)
                ], // Xanh lá sáng nhẹ
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRow('Lãi trong tháng', mProfit),
                  const Divider(color: Colors.white, height: 24),
                  _buildRow('Lãi trong quý (6 tháng)', qProfit),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Lỗi: $e'),
    );
  }

  Widget _buildRow(String label, double profit) {
    final isProfit = profit >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;
    final icon = isProfit ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
        Text(
          CurrencyFormatter.format(profit),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900, // Very bold
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final MonthlyStatEntity stat;
  final int year;
  const _MonthlyRow({required this.stat, required this.year});

  static const _monthNames = [
    '',
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
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
            Text('${_monthNames[stat.month]} / $year',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatChip(
                    label: '↓ Thu',
                    amount: stat.totalIncome,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                    label: '↑ Chi',
                    amount: stat.totalExpense,
                    color: AppColors.error),
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
  const _StatChip(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13),
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
    final weekdays = [
      '',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    final weekdayStr = weekdays[stat.date.weekday];
    final dateStr =
        '${stat.date.day.toString().padLeft(2, '0')}/${stat.date.month.toString().padLeft(2, '0')}/${stat.date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$weekdayStr, $dateStr',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (stat.income > 0)
                  Text('+ ${CurrencyFormatter.formatCompact(stat.income)}',
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                if (stat.expense > 0)
                  Text('- ${CurrencyFormatter.formatCompact(stat.expense)}',
                      style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
