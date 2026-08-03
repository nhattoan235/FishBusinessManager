import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/product_provider.dart';
import '../../domain/entities/product_entity.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductEntity? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _initialStockController;
  late final TextEditingController _noteController;

  int? _selectedCategoryId;
  int? _selectedUnitId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
        text: widget.product?.defaultPrice?.toString() ?? '');
    _initialStockController = TextEditingController();
    _noteController = TextEditingController(text: widget.product?.note ?? '');
    _selectedCategoryId = widget.product?.categoryId;
    _selectedUnitId = widget.product?.unitId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _initialStockController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn đơn vị tính')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final price = int.tryParse(_priceController.text.trim());
      final initialStock = widget.product == null
          ? double.parse(
              _initialStockController.text.trim().replaceAll(',', '.').isEmpty
                  ? '0'
                  : _initialStockController.text.trim().replaceAll(',', '.'),
            )
          : 0.0;
      final product = ProductEntity(
        id: widget.product?.id,
        uuid: widget.product?.uuid ?? const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        unitId: _selectedUnitId!,
        name: _nameController.text.trim(),
        defaultPrice: price,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isActive: true,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      await ref.read(productRepositoryProvider).saveProduct(
            product,
            initialStock: initialStock,
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thông tin sản phẩm')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.product?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
              onPressed: () => context.pop(false), child: const Text('Hủy')),
          FilledButton(
              onPressed: () => context.pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(productRepositoryProvider)
            .deleteProduct(widget.product!.id!);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa sản phẩm')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final unitsAsync = ref.watch(productUnitsProvider);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _delete,
            )
        ],
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm (*)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category Dropdown
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục (*)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategoryId = val),
                        validator: (val) =>
                            val == null ? 'Bắt buộc chọn' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text('Lỗi tải danh mục: $err'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Unit Dropdown
                    unitsAsync.when(
                      data: (units) => DropdownButtonFormField<int>(
                        value: _selectedUnitId,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị tính (*)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                        ),
                        items: units
                            .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text('${u.name} (${u.symbol})'),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedUnitId = val),
                        validator: (val) =>
                            val == null ? 'Bắt buộc chọn' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text('Lỗi tải đơn vị: $err'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá bán mặc định (không bắt buộc)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (!isEditing) ...[
                      TextFormField(
                        controller: _initialStockController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Số lượng ban đầu (không bắt buộc)',
                          hintText: 'Ví dụ: 25,5',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.inventory),
                          suffixText: unitsAsync.valueOrNull
                              ?.where((unit) => unit.id == _selectedUnitId)
                              .firstOrNull
                              ?.symbol,
                          helperText:
                              'Số lượng này sẽ được ghi vào lịch sử kho.',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          final quantity =
                              double.tryParse(text.replaceAll(',', '.'));
                          if (quantity == null) {
                            return 'Số lượng không hợp lệ';
                          }
                          if (!quantity.isFinite || quantity < 0) {
                            return 'Số lượng phải lớn hơn hoặc bằng 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
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
                      child: const Text('Lưu thông tin',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
