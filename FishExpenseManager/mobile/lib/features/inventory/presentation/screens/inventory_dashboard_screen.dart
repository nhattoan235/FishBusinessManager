import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/inventory_provider.dart';

class InventoryDashboardScreen extends ConsumerStatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  ConsumerState<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends ConsumerState<InventoryDashboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventorySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử kho',
            onPressed: () => context.push('/inventory/history'),
          ),
        ],
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
            child: inventoryAsync.when(
              data: (summaryList) {
                final filteredList = summaryList.where((item) {
                  return item.product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu tồn kho'));
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final summary = filteredList[index];
                    final isLowStock = summary.currentStock <= 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLowStock
                              ? AppColors.error.withAlpha(26)
                              : AppColors.success.withAlpha(26),
                          child: Icon(
                            isLowStock ? Icons.warning_amber_rounded : Icons.inventory,
                            color: isLowStock ? AppColors.error : AppColors.success,
                          ),
                        ),
                        title: Text(summary.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${summary.product.id}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              summary.currentStock.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), ''),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? AppColors.error : null,
                              ),
                            ),
                            const Text('Tồn kho', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        onTap: () {
                          context.push('/inventory/adjust/${summary.product.id}', extra: summary.product);
                        },
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
    );
  }
}
