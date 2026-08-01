import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction_entity.dart';

// --- Local Provider for Details ---
class TransactionDetailInfo {
  final TransactionEntity transaction;
  final String? customerName;
  final List<SaleItemDetail> saleItems;
  final double? remainingDebt;

  TransactionDetailInfo({
    required this.transaction,
    this.customerName,
    this.saleItems = const [],
    this.remainingDebt,
  });
}

class SaleItemDetail {
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItemDetail({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

final transactionDetailFutureProvider =
    FutureProvider.family<TransactionDetailInfo?, int>((ref, transactionId) async {
  final db = ref.watch(databaseProvider);

  // Lấy transaction
  final txRow = await (db.select(db.transactions)
        ..where((t) => t.id.equals(transactionId)))
      .getSingleOrNull();

  if (txRow == null) return null;

  final txEntity = TransactionEntity(
    id: txRow.id,
    uuid: txRow.uuid,
    amount: txRow.amount.toDouble(),
    isIncome: txRow.isIncome,
    type: txRow.type,
    description: txRow.description ?? '',
    date: txRow.date,
    referenceId: txRow.referenceId,
    createdAt: txRow.createdAt,
  );

  String? customerName;
  List<SaleItemDetail> saleItems = [];
  double? remainingDebt;

  // Phân tích theo loại
  if (txEntity.type == 'Bán hàng' && txEntity.referenceId != null) {
    // Truy vấn phiếu bán
    final saleDoc = await (db.select(db.saleDocuments)
          ..where((t) => t.uuid.equals(txEntity.referenceId!)))
        .getSingleOrNull();

    if (saleDoc != null) {
      // Lấy tên khách
      final customer = await (db.select(db.customers)
            ..where((t) => t.id.equals(saleDoc.customerId)))
          .getSingleOrNull();
      customerName = customer?.name;

      // Lấy danh sách item
      final itemsResult = await db.customSelect(
        '''
        SELECT p.name as product_name, si.quantity, si.unit_price, si.total_price
        FROM sale_items si
        JOIN products p ON p.id = si.product_id
        WHERE si.sale_document_id = ?
        ''',
        variables: [drift.Variable.withInt(saleDoc.id)],
        readsFrom: {db.saleItems, db.products},
      ).get();

      saleItems = itemsResult.map((r) {
        return SaleItemDetail(
          productName: r.read<String>('product_name'),
          quantity: r.read<double>('quantity'),
          unitPrice: r.read<int>('unit_price').toDouble(),
          totalPrice: r.read<int>('total_price').toDouble(),
        );
      }).toList();
    }
  } else if (txEntity.type == 'Thu nợ' && txEntity.referenceId != null) {
    // Thu nợ lưu referenceId là customerId. Convert to int.
    final custId = int.tryParse(txEntity.referenceId ?? '');
    if (custId != null) {
      final customer = await (db.select(db.customers)
            ..where((t) => t.id.equals(custId)))
          .getSingleOrNull();
      customerName = customer?.name;

      final balance = await (db.select(db.customerBalances)
            ..where((t) => t.customerId.equals(custId)))
          .getSingleOrNull();
      remainingDebt = balance?.currentDebt.toDouble() ?? 0.0;
    }
  }

  return TransactionDetailInfo(
    transaction: txEntity,
    customerName: customerName,
    saleItems: saleItems,
    remainingDebt: remainingDebt,
  );
});

// --- Widget ---
class TransactionDetailScreen extends ConsumerWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailFutureProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Giao dịch'),
      ),
      body: detailAsync.when(
        data: (info) {
          if (info == null) {
            return const Center(child: Text('Không tìm thấy giao dịch.'));
          }

          final tx = info.transaction;
          final color = tx.isIncome ? AppColors.success : AppColors.error;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ Thông tin chung
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(tx.type, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          CurrencyFormatter.formatWithSign(tx.amount, isIncome: tx.isIncome),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(DateFormatter.formatDateTime(tx.date)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Thẻ Chi tiết theo loại
                if (tx.type == 'Bán hàng' && info.saleItems.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chi tiết Bán hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildDetailRow('Khách hàng', info.customerName ?? 'Không rõ'),
                          const SizedBox(height: AppSpacing.sm),
                          const Text('Mặt hàng:', style: TextStyle(fontWeight: FontWeight.w500)),
                          ...info.saleItems.map((item) => Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.sm),
                                child: Text('• ${item.productName}: ${item.quantity} kg x ${CurrencyFormatter.format(item.unitPrice)} = ${CurrencyFormatter.format(item.totalPrice)}'),
                              )),
                        ],
                      ),
                    ),
                  ),

                if (tx.type == 'Thu nợ')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chi tiết Thu nợ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildDetailRow('Khách hàng', info.customerName ?? 'Không rõ'),
                          _buildDetailRow('Số tiền đã thu', CurrencyFormatter.format(tx.amount)),
                          if (info.remainingDebt != null)
                            _buildDetailRow('Nợ còn lại', CurrencyFormatter.format(info.remainingDebt!)),
                        ],
                      ),
                    ),
                  ),

                if (tx.type != 'Bán hàng' && tx.type != 'Thu nợ')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thông tin khác', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildDetailRow('Ghi chú', tx.description.isNotEmpty ? tx.description : 'Không có'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
