import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/product_provider.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(product.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/products/edit/${product.id}', extra: product),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Thông tin cơ bản ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin sản phẩm',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        _InfoRow(label: 'Danh mục', value: product.category?.name ?? '—'),
                        _InfoRow(label: 'Đơn vị', value: product.unit != null
                            ? '${product.unit!.name} (${product.unit!.symbol})' : '—'),
                        if (product.defaultPrice != null)
                          _InfoRow(
                            label: 'Giá mặc định',
                            value: CurrencyFormatter.format(product.defaultPrice!.toDouble()),
                          ),
                        if (product.note != null && product.note!.isNotEmpty)
                          _InfoRow(label: 'Ghi chú', value: product.note!),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Tồn kho hiện tại ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  color: detail.currentStock > 0
                      ? AppColors.success.withAlpha(20)
                      : AppColors.error.withAlpha(20),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          detail.currentStock > 0 ? Icons.inventory : Icons.warning_amber,
                          color: detail.currentStock > 0 ? AppColors.success : AppColors.error,
                          size: 36,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tồn kho hiện tại',
                                style: TextStyle(color: AppColors.textSecondary)),
                            Text(
                              '${detail.currentStock.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} ${product.unit?.symbol ?? ''}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: detail.currentStock > 0 ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Lịch sử nhập kho ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lịch sử nhập kho',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),
                    if (detail.inventoryEntries.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text('Chưa có dữ liệu nhập kho',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ...detail.inventoryEntries.map((e) => Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.success.withAlpha(26),
                                child: const Icon(Icons.arrow_downward, color: AppColors.success),
                              ),
                              title: Text(e.typeLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                e.note ?? DateFormat('dd/MM/yyyy HH:mm').format(e.createdAt),
                              ),
                              trailing: Text(
                                '+${e.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
                                style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          )),
                  ],
                ),
              ),

              // ─── Lịch sử bán ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lịch sử bán hàng',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),
                    if (detail.saleHistory.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text('Chưa có lịch sử bán',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ...detail.saleHistory.map((s) => Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withAlpha(26),
                                child: const Icon(Icons.shopping_cart, color: AppColors.primary),
                              ),
                              title: Text(s.customerName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${s.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} × ${CurrencyFormatter.format(s.unitPrice)}'),
                                  Text(DateFormat('dd/MM/yyyy').format(s.saleDate)),
                                ],
                              ),
                              trailing: Text(
                                CurrencyFormatter.format(s.subtotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              isThreeLine: true,
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
