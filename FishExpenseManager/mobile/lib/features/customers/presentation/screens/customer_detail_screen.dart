import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../application/customer_provider.dart';
import '../../../debts/application/debt_provider.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final debtsAsync = ref.watch(debtListProvider);

    return customersAsync.when(
      data: (customers) {
        final customer = customers.where((c) => c.id == customerId).firstOrNull;
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Khách hàng')),
            body: const Center(child: Text('Không tìm thấy khách hàng.')),
          );
        }

        // Find debt for this customer
        double debtBalance = 0;
        debtsAsync.whenData((debts) {
          final found = debts.where((d) => d.customerId == customerId).firstOrNull;
          if (found != null) debtBalance = found.balance;
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/customers/edit/$customerId'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin khách hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _infoRow(Icons.person, 'Tên', customer.name),
                        _infoRow(Icons.phone, 'SĐT', customer.phone ?? 'Chưa có'),
                        _infoRow(Icons.location_on, 'Địa chỉ', customer.address ?? 'Chưa có'),
                        _infoRow(Icons.note, 'Ghi chú', customer.note ?? 'Chưa có'),
                        _infoRow(Icons.calendar_today, 'Ngày tạo', DateFormatter.formatDate(customer.createdAt)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Debt summary
                Card(
                  color: debtBalance > 0 ? AppColors.error.withValues(alpha: 0.05) : AppColors.success.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Công nợ hiện tại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              CurrencyFormatter.format(debtBalance),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: debtBalance > 0 ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        if (debtBalance > 0)
                          ElevatedButton.icon(
                            onPressed: () => context.push('/debts/collect/$customerId'),
                            icon: const Icon(Icons.payments, color: Colors.white),
                            label: const Text('Thu Nợ', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Placeholder for purchase history & payment history
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lịch sử mua hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text('Chưa có lịch sử mua hàng', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lịch sử thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text('Chưa có lịch sử thanh toán', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa khách hàng này? (Xóa mềm)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(customerRepositoryProvider);
              await repo.deleteCustomer(customerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa khách hàng')));
                context.pop();
              }
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
