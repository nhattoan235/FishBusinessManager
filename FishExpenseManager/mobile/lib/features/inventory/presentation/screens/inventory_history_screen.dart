import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/inventory_provider.dart';

class InventoryHistoryScreen extends ConsumerWidget {
  const InventoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(inventoryHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử kho hàng'),
      ),
      body: historyAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử biến động kho'));
          }

          return ListView.separated(
            itemCount: entries.length,
            padding: const EdgeInsets.all(AppSpacing.sm),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isPositive = entry.quantity > 0;
              final color = isPositive ? AppColors.success : AppColors.error;
              
              String typeLabel = entry.entryType;
              if (entry.entryType == 'sale') typeLabel = 'Bán hàng';
              else if (entry.entryType == 'purchase') typeLabel = 'Nhập hàng';
              else if (entry.entryType == 'adjustment') typeLabel = 'Điều chỉnh';
              else if (entry.entryType == 'harvest') typeLabel = 'Thu hoạch';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(26),
                  child: Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                  ),
                ),
                title: Text(entry.product?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loại: $typeLabel'),
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(entry.createdAt)),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text('Ghi chú: ${entry.note}'),
                  ],
                ),
                trailing: Text(
                  '${isPositive ? '+' : ''}${entry.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                isThreeLine: true,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
