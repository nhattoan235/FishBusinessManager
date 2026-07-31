import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  
  bool _isIncome = true;
  String _type = 'Bán hàng';
  DateTime _date = DateTime.now();

  final _incomeTypes = ['Bán hàng', 'Thu nợ', 'Khác'];
  final _expenseTypes = ['Mua hàng', 'Chi phí', 'Trả nợ', 'Khác'];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      try {
        final useCase = ref.read(recordTransactionUseCaseProvider);
        await useCase.execute(
          amount: amount,
          isIncome: _isIncome,
          type: _type,
          description: _descController.text,
          date: _date,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu giao dịch')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = _isIncome ? _incomeTypes : _expenseTypes;
    if (!types.contains(_type)) {
      _type = types.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Giao Dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Thu Tiền'), icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(value: false, label: Text('Chi Tiền'), icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_isIncome},
                onSelectionChanged: (set) {
                  setState(() => _isIncome = set.first);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tiền (đ)', border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập số tiền';
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Loại giao dịch', border: OutlineInputBorder()),
                items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md)),
                child: const Text('Lưu', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
