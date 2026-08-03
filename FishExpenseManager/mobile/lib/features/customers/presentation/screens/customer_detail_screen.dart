import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/database/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../application/customer_provider.dart';
import '../../../debts/application/debt_provider.dart';

// --- Local Provider cho Lịch sử ---
class CustomerHistoryInfo {
  final List<SaleHistoryItem> purchases;
  final List<PaymentHistoryItem> payments;

  CustomerHistoryInfo(this.purchases, this.payments);
}

class SaleHistoryItem {
  final DateTime date;
  final int totalAmount;
  final int paidAmount;

  SaleHistoryItem(this.date, this.totalAmount, this.paidAmount);
}

class PaymentHistoryItem {
  final DateTime date;
  final int amount;
  final String source;

  PaymentHistoryItem(this.date, this.amount, this.source);
}

final customerHistoryProvider = StreamProvider.autoDispose
    .family<CustomerHistoryInfo, int>((ref, customerId) {
  final db = ref.watch(databaseProvider);
  final changes = db.customSelect(
    'SELECT ? AS customer_id',
    variables: [drift.Variable.withInt(customerId)],
    readsFrom: {db.saleDocuments, db.debtTransactions},
  ).watch();

  return changes.asyncMap((_) async {
    final sales = await (db.select(db.saleDocuments)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.saleDate, mode: drift.OrderingMode.desc)
          ]))
        .get();

    final debtPayments = await (db.select(db.debtTransactions)
          ..where((t) =>
              t.customerId.equals(customerId) & t.changeType.equals('decrease'))
          ..orderBy([
            (t) => drift.OrderingTerm(
                  expression: t.createdAt,
                  mode: drift.OrderingMode.desc,
                )
          ]))
        .get();

    final purchaseItems = sales
        .map((s) => SaleHistoryItem(s.saleDate, s.totalAmount, s.paidAmount))
        .toList();

    final paymentItems = <PaymentHistoryItem>[
      ...sales
          .where((sale) => sale.paidAmount > 0)
          .map((sale) => PaymentHistoryItem(
                sale.saleDate,
                sale.paidAmount,
                'Thanh toán khi mua hàng',
              )),
      ...debtPayments.map((payment) => PaymentHistoryItem(
            payment.createdAt,
            payment.amount,
            'Thu nợ',
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return CustomerHistoryInfo(purchaseItems, paymentItems);
  });
});

class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final debtsAsync = ref.watch(debtListProvider);
    final historyAsync = ref.watch(customerHistoryProvider(customerId));

    return customerAsync.when(
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Khách hàng')),
            body: const Center(child: Text('Không tìm thấy khách hàng.')),
          );
        }

        // Safely calculate debt balance
        double debtBalance = 0;
        final debtsData = debtsAsync.valueOrNull;
        if (debtsData != null) {
          final found =
              debtsData.where((d) => d.customerId == customerId).firstOrNull;
          if (found != null) {
            debtBalance = found.balance;
          }
        }

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
          body: SafeArea(
            child: SingleChildScrollView(
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
                          const Text('Thông tin khách hàng',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _infoRow(Icons.person, 'Tên', customer.name),
                          _infoRow(
                              Icons.phone,
                              'SĐT',
                              (customer.phone?.trim().isNotEmpty == true)
                                  ? customer.phone!
                                  : 'Chưa có'),
                          _infoRow(
                              Icons.location_on,
                              'Địa chỉ',
                              (customer.address?.trim().isNotEmpty == true)
                                  ? customer.address!
                                  : 'Chưa có'),
                          _infoRow(
                              Icons.note,
                              'Ghi chú',
                              (customer.note?.trim().isNotEmpty == true)
                                  ? customer.note!
                                  : 'Chưa có'),
                          _infoRow(Icons.calendar_today, 'Ngày tạo',
                              DateFormatter.formatDate(customer.createdAt)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Debt summary
                  Card(
                    color: debtBalance > 0
                        ? AppColors.error.withOpacity(0.05)
                        : AppColors.success.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Công nợ hiện tại',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  CurrencyFormatter.format(debtBalance),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: debtBalance > 0
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (debtBalance > 0)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/debts/collect/$customerId'),
                              icon: const Icon(Icons.payments,
                                  color: Colors.white),
                              label: const Text('Thu Nợ',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // History
                  historyAsync.when(
                    data: (info) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Purchase history
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lịch sử mua hàng',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Divider(),
                                if (info.purchases.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(AppSpacing.lg),
                                      child: Text('Chưa có lịch sử mua hàng',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                else
                                  ...info.purchases.take(5).map((p) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                            Icons.shopping_cart_checkout,
                                            color: AppColors.primary),
                                        title: Text(
                                            DateFormatter.formatDate(p.date)),
                                        subtitle: Text(
                                            'Đã trả: ${CurrencyFormatter.format(p.paidAmount.toDouble())}'),
                                        trailing: Text(
                                            CurrencyFormatter.format(
                                                p.totalAmount.toDouble()),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Payment history
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lịch sử thanh toán',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Divider(),
                                if (info.payments.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(AppSpacing.lg),
                                      child: Text('Chưa có lịch sử thanh toán',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                else
                                  ...info.payments.take(5).map((p) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.payments,
                                            color: AppColors.success),
                                        title: Text(
                                            DateFormatter.formatDateTime(
                                                p.date)),
                                        subtitle: Text(p.source),
                                        trailing: Text(
                                            '+${CurrencyFormatter.format(p.amount.toDouble())}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.success)),
                                      )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) =>
                        Center(child: Text('Lỗi tải lịch sử: $err')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Đang tải...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = ref.read(customerRepositoryProvider);
                await repo.deleteCustomer(customerId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa khách hàng')),
                  );
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/customers');
                  }
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể xóa khách hàng: $error')),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
