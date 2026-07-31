import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customers/application/customer_provider.dart';
import '../../../products/application/product_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../application/sale_provider.dart';
import '../../domain/entities/sale_entity.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});

  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _paidController = TextEditingController();

  int? _selectedCustomerId;
  ProductEntity? _selectedProduct;

  double get _totalAmount {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return qty * price;
  }

  double get _debtAmount {
    final paid = double.tryParse(_paidController.text) ?? 0;
    return (_totalAmount - paid).clamp(0, double.infinity);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn khách hàng')));
      return;
    }
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sản phẩm')));
      return;
    }

    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final paid = double.tryParse(_paidController.text) ?? 0;
    final total = qty * price;

    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng và đơn giá phải > 0')));
      return;
    }
    if (paid > total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiền trả không được lớn hơn tổng tiền')));
      return;
    }
    
    // Kiểm tra tồn kho (BR-005)
    final currentStock = _selectedProduct!.currentStock ?? 0;
    if (qty > currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: Số lượng bán ($qty) vượt quá tồn kho hiện tại ($currentStock)'),
          backgroundColor: AppColors.error,
        )
      );
      return;
    }

    try {
      final useCase = ref.read(createSaleUseCaseProvider);
      await useCase.execute(
        customerId: _selectedCustomerId!,
        totalAmount: total,
        paidAmount: paid,
        saleDate: DateTime.now(),
        items: [
          SaleItemEntity(
            productId: _selectedProduct!.id!,
            quantity: qty,
            unitPrice: price,
            subTotal: total,
          ),
        ],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu phiếu bán hàng!')));
        // Reset form
        _qtyController.clear();
        _priceController.clear();
        _paidController.clear();
        setState(() {
          _selectedCustomerId = null;
          // Refresh products to get updated stock
          ref.invalidate(productListProvider);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _onProductSelected(ProductEntity? product) {
    setState(() {
      _selectedProduct = product;
      if (product?.defaultPrice != null) {
        _priceController.text = product!.defaultPrice.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bán hàng'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tạo Phiếu Bán Hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Customer dropdown
              customersAsync.when(
                data: (customers) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Chọn Khách Hàng *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCustomerId = val),
                    validator: (val) => val == null ? 'Vui lòng chọn khách hàng' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Lỗi tải khách hàng: $e'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Product selection
              productsAsync.when(
                data: (products) {
                  final activeProducts = products.where((p) => p.isActive).toList();
                  
                  if (activeProducts.isEmpty) {
                    return const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sản phẩm',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning, color: AppColors.error),
                      ),
                      child: Text('Chưa có sản phẩm nào. Vui lòng thêm sản phẩm.'),
                    );
                  }

                  // If exactly 1 product, auto-select it and show as readonly
                  if (activeProducts.length == 1) {
                    final p = activeProducts.first;
                    if (_selectedProduct == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onProductSelected(p);
                      });
                    }
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Sản phẩm (mặc định)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      child: Text('${p.name} (Tồn kho: ${p.currentStock ?? 0} ${p.unit?.symbol ?? ''})'),
                    );
                  }

                  // If multiple products, show dropdown
                  return DropdownButtonFormField<ProductEntity>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Chọn Sản Phẩm *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    items: activeProducts.map((p) => DropdownMenuItem(
                      value: p, 
                      child: Text('${p.name} (Tồn kho: ${p.currentStock ?? 0} ${p.unit?.symbol ?? ''})')
                    )).toList(),
                    onChanged: _onProductSelected,
                    validator: (val) => val == null ? 'Vui lòng chọn sản phẩm' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Lỗi tải sản phẩm: $e'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Quantity
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số Lượng (${_selectedProduct?.unit?.symbol ?? 'kg'}) *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.scale),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nhập số lượng';
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return 'Không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Unit Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Đơn Giá (đ) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nhập đơn giá';
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return 'Không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Total
              Card(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        CurrencyFormatter.format(_totalAmount),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Paid amount
              TextFormField(
                controller: _paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiền khách trả (đ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Debt display
              if (_debtAmount > 0)
                Card(
                  color: AppColors.error.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Còn nợ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          CurrencyFormatter.format(_debtAmount),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Lưu Phiếu Bán Hàng', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
