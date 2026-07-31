import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../application/debt_provider.dart';

class DebtListScreen extends ConsumerStatefulWidget {
  const DebtListScreen({super.key});

  @override
  ConsumerState<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends ConsumerState<DebtListScreen> {
  String _filter = 'owing'; // 'owing' or 'all'

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Công nợ'), centerTitle: true),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _buildFilterChip('Còn nợ', 'owing'),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Tất cả', 'all'),
              ],
            ),
          ),
          // List
          Expanded(
            child: debtsAsync.when(
              data: (debts) {
                final filtered = _filter == 'owing'
                    ? debts.where((d) => d.balance > 0).toList()
                    : debts;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: AppSpacing.md),
                        const Text('Không có khách hàng nợ.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final debt = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: debt.balance > 0 ? AppColors.warning : AppColors.success,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(debt.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Cập nhật: ${DateFormatter.formatDate(debt.lastUpdatedAt)}'),
                        trailing: Text(
                          CurrencyFormatter.format(debt.balance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: debt.balance > 0 ? AppColors.error : AppColors.success,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          if (debt.balance > 0) {
                            context.push('/debts/collect/${debt.customerId}');
                          }
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

  Widget _buildFilterChip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
      selected: selected,
      selectedColor: AppColors.primary,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
