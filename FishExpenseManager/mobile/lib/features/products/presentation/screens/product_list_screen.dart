import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/string_utils.dart';
import '../../application/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục Sản phẩm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final activeProducts = products.where((p) => p.isActive).toList();
                final filteredProducts = activeProducts.where((p) {
                  return p.name.toLowerCase().withoutDiacritics.contains(_searchQuery.toLowerCase().withoutDiacritics);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm nào'));
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final stock = product.currentStock ?? 0;
                    final isLow = stock <= 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.info.withAlpha(26),
                          child: const Icon(Icons.inventory_2, color: AppColors.info),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${product.category?.name ?? 'Không có'} • ${product.unit?.symbol ?? ''}'),
                            if (product.defaultPrice != null)
                              Text('Giá: ${CurrencyFormatter.format(product.defaultPrice!.toDouble())}'),
                          ],
                        ),
                        trailing: Text(
                          '${stock.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} ${product.unit?.symbol ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLow ? AppColors.error : AppColors.success,
                          ),
                        ),
                        isThreeLine: product.defaultPrice != null,
                        onTap: () => context.push('/products/${product.id}', extra: product),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/products/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
