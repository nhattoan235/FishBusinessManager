import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/debt_provider.dart';

class CollectDebtScreen extends ConsumerStatefulWidget {
  final int customerId;

  const CollectDebtScreen({super.key, required this.customerId});

  @override
  ConsumerState<CollectDebtScreen> createState() => _CollectDebtScreenState();
}

class _CollectDebtScreenState extends ConsumerState<CollectDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    try {
      final repo = ref.read(debtRepositoryProvider);
      await repo.collectDebt(
        customerId: widget.customerId,
        amount: amount,
        date: DateTime.now(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thu nợ thành công!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thu Nợ')),
      body: debtsAsync.when(
        data: (debts) {
          final debt = debts.where((d) => d.customerId == widget.customerId).firstOrNull;
          if (debt == null) {
            return const Center(child: Text('Không tìm thấy thông tin công nợ.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(debt.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (debt.customerPhone != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text('SĐT: ${debt.customerPhone}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Current debt
                  Card(
                    color: AppColors.error.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          const Text('Số tiền đang nợ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            CurrencyFormatter.format(debt.balance),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền thu *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments),
                      hintText: 'Nhập số tiền muốn thu',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Vui lòng nhập số tiền';
                      final n = double.tryParse(val);
                      if (n == null || n <= 0) return 'Số tiền phải > 0';
                      if (n > debt.balance) return 'Không được thu vượt quá số nợ (${CurrencyFormatter.format(debt.balance)})';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Quick amount buttons
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _quickAmountChip('Trả hết', debt.balance),
                      if (debt.balance >= 1000000) _quickAmountChip('1 triệu', 1000000),
                      if (debt.balance >= 500000) _quickAmountChip('500k', 500000),
                      if (debt.balance >= 2000000) _quickAmountChip('2 triệu', 2000000),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Xác nhận Thu Nợ', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _quickAmountChip(String label, double amount) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(0);
        setState(() {});
      },
    );
  }
}
