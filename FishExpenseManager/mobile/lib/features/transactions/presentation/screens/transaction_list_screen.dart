import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../application/transaction_provider.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  String _searchQuery = '';
  String _filterPeriod = 'all'; // 'all', 'today', 'week', 'month'

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thu chi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('Hôm nay', 'today'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('Tuần', 'week'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('Tháng', 'month'),
              ],
            ),
          ),
          // List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _applyFilters(transactions);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Không có giao dịch phù hợp.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildTransactionItem(filtered[index]),
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
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _filterPeriod == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black87)),
      selected: selected,
      selectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: (_) => setState(() => _filterPeriod = value),
    );
  }

  List<TransactionEntity> _applyFilters(List<TransactionEntity> all) {
    var result = all;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((tx) =>
        tx.type.toLowerCase().contains(_searchQuery) ||
        tx.description.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    // Period filter
    final now = DateTime.now();
    switch (_filterPeriod) {
      case 'today':
        result = result.where((tx) =>
          tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day
        ).toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        result = result.where((tx) => tx.date.isAfter(weekAgo)).toList();
        break;
      case 'month':
        result = result.where((tx) =>
          tx.date.year == now.year && tx.date.month == now.month
        ).toList();
        break;
    }

    return result;
  }

  Widget _buildTransactionItem(TransactionEntity tx) {
    final color = tx.isIncome ? AppColors.success : AppColors.error;
    final icon = tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(tx.type, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tx.description.isNotEmpty) Text(tx.description),
            Text(DateFormatter.formatDateTime(tx.date)),
          ],
        ),
        trailing: Text(
          CurrencyFormatter.formatWithSign(tx.amount, isIncome: tx.isIncome),
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
      ),
    );
  }
}
