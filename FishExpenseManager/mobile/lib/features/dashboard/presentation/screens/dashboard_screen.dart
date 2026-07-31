import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../application/dashboard_provider.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
      ),
      body: summaryAsync.when(
        data: (summary) => _buildDashboardContent(context, ref, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.go('/sales'),
        icon: const Icon(Icons.point_of_sale),
        label: const Text('Bán Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref, DashboardSummary summary) {
    return RefreshIndicator(
      onRefresh: () async {
        // ignore: unused_result
        ref.refresh(dashboardSummaryProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTotalCashCard(summary.totalCash),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildInfoCard('Thu hôm nay', summary.todayIncome, AppColors.success, Icons.arrow_downward)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildInfoCard('Chi hôm nay', summary.todayExpense, AppColors.error, Icons.arrow_upward)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildInfoCard('Khách nợ', summary.totalReceivables, AppColors.warning, Icons.account_balance_wallet)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildInfoCard('Tồn kho', summary.totalInventory, AppColors.primary, Icons.inventory_2, isCurrency: false)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Thao tác nhanh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(context, 'Thu Tiền', Icons.payments, AppColors.success, () {
                  context.go('/debts');
                }),
                _buildQuickAction(context, 'Thêm Chi', Icons.money_off, AppColors.error, () {
                  context.push('/transactions/add');
                }),
                _buildQuickAction(context, 'Báo Cáo', Icons.bar_chart, AppColors.primary, () {
                  // Giai đoạn 3
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Báo cáo sẽ có ở Giai đoạn 3')));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCashCard(double amount) {
    return AppCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text('Tiền hiện có', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color color, IconData icon, {bool isCurrency = true}) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isCurrency ? CurrencyFormatter.format(amount) : '${amount.toStringAsFixed(1)} kg',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
