import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../application/inventory_provider.dart';

class InventoryAdjustmentScreen extends ConsumerStatefulWidget {
  final ProductEntity product;
  
  const InventoryAdjustmentScreen({super.key, required this.product});

  @override
  ConsumerState<InventoryAdjustmentScreen> createState() => _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState extends ConsumerState<InventoryAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isAddition = true; // true = nhập, false = xuất
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final qty = double.parse(_quantityController.text.trim());
      final diff = _isAddition ? qty : -qty;

      await ref.read(inventoryRepositoryProvider).adjustInventory(
        productId: widget.product.id!,
        difference: diff,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật tồn kho')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều chỉnh kho'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            const Text('Sản phẩm', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.name, 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Nhập (+)'),
                            value: true,
                            groupValue: _isAddition,
                            onChanged: (val) => setState(() => _isAddition = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Xuất/Hủy (-)'),
                            value: false,
                            groupValue: _isAddition,
                            onChanged: (val) => setState(() => _isAddition = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Số lượng thay đổi (*)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(_isAddition ? Icons.add_circle : Icons.remove_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số lượng';
                        if (double.tryParse(value.trim()) == null) return 'Số lượng không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú / Lý do điều chỉnh',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      child: const Text('Xác nhận điều chỉnh', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
