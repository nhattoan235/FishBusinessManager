import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../application/debt_provider.dart';
import '../../../customers/application/customer_provider.dart';

// --- Data Models ---
class DebtTransactionDetail {
  final int saleId;
  final DateTime saleDate;
  final int totalAmount;
  final int paidAmount;
  final int debtAmount;
  final String? note;
  final List<DebtSaleItem> items;

  DebtTransactionDetail({
    required this.saleId,
    required this.saleDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    this.note,
    required this.items,
  });

  String get summaryProducts {
    if (items.isEmpty) return 'Không có mặt hàng';
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} và ${items.length - 1} mặt hàng khác';
  }
}

class DebtSaleItem {
  final String productName;
  final double quantity;
  final int unitPrice;
  final int totalPrice;

  DebtSaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

// --- Provider ---
final debtDetailProvider = StreamProvider.family<List<DebtTransactionDetail>, int>((ref, customerId) async* {
  final db = ref.watch(databaseProvider);

  // Watch all sales for this customer that have debt > 0
  final salesStream = (db.select(db.saleDocuments)
        ..where((t) => t.customerId.equals(customerId) & t.debtAmount.isBiggerThanValue(0))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.saleDate, mode: drift.OrderingMode.desc)]))
      .watch();

  await for (final sales in salesStream) {
    List<DebtTransactionDetail> details = [];

    for (final sale in sales) {
      // Fetch items for this sale
      final itemsResult = await db.customSelect(
        '''
        SELECT p.name as product_name, si.quantity, si.unit_price, si.total_price
        FROM sale_items si
        JOIN products p ON p.id = si.product_id
        WHERE si.sale_document_id = ?
        ''',
        variables: [drift.Variable.withInt(sale.id)],
        readsFrom: {db.saleItems, db.products},
      ).get();

      final items = itemsResult.map((r) {
        return DebtSaleItem(
          productName: r.read<String>('product_name'),
          quantity: r.read<double>('quantity'),
          unitPrice: r.read<int>('unit_price'),
          totalPrice: r.read<int>('total_price'),
        );
      }).toList();

      details.add(DebtTransactionDetail(
        saleId: sale.id,
        saleDate: sale.saleDate,
        totalAmount: sale.totalAmount,
        paidAmount: sale.paidAmount,
        debtAmount: sale.debtAmount,
        note: sale.note,
        items: items,
      ));
    }

    yield details;
  }
});

// --- UI ---
class DebtDetailScreen extends ConsumerWidget {
  final int customerId;

  const DebtDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(debtDetailProvider(customerId));
    final customersAsync = ref.watch(customersProvider);

    // Get customer name
    String customerName = 'Chi tiết công nợ';
    customersAsync.whenData((customers) {
      final cust = customers.where((c) => c.id == customerId).firstOrNull;
      if (cust != null) customerName = 'Công nợ: ${cust.name}';
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(customerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.payments),
            tooltip: 'Thu nợ',
            onPressed: () {
              context.push('/debts/collect/$customerId');
            },
          )
        ],
      ),
      body: detailsAsync.when(
        data: (details) {
          if (details.isEmpty) {
            return const Center(child: Text('Khách hàng này không có giao dịch nợ nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.sm),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final item = details[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ExpansionTile(
                  title: Text(
                    DateFormatter.formatDate(item.saleDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Mặt hàng: ${item.summaryProducts}', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Đã trả: ${CurrencyFormatter.format(item.paidAmount.toDouble())}',
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Chi tiết mua hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.sm),
                          // List of products
                          ...item.items.map((prod) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        '${prod.productName}\n${prod.quantity} kg x ${CurrencyFormatter.format(prod.unitPrice.toDouble())}',
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(prod.totalPrice.toDouble()),
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),
                          _buildDetailRow('Tổng cộng:', CurrencyFormatter.format(item.totalAmount.toDouble()), isBold: true),
                          _buildDetailRow('Đã thanh toán:', CurrencyFormatter.format(item.paidAmount.toDouble()), color: AppColors.success),
                          _buildDetailRow('Còn nợ phiếu này:', CurrencyFormatter.format(item.debtAmount.toDouble()), color: AppColors.error, isBold: true),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _buildDetailRow('Ghi chú:', item.note!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/debts/collect/$customerId'),
        icon: const Icon(Icons.payments),
        label: const Text('Thu nợ'),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
