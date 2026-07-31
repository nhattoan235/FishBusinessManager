import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/supplier_provider.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà cung cấp'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, SĐT...',
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
            child: suppliersAsync.when(
              data: (suppliers) {
                final activeSuppliers = suppliers.where((s) => s.isActive).toList();
                final filteredSuppliers = activeSuppliers.where((s) {
                  final query = _searchQuery.toLowerCase();
                  return s.name.toLowerCase().contains(query) ||
                      (s.phone?.toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredSuppliers.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu nhà cung cấp'));
                }

                return ListView.builder(
                  itemCount: filteredSuppliers.length,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final supplier = filteredSuppliers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withAlpha(26),
                          child: const Icon(Icons.business, color: AppColors.primary),
                        ),
                        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(supplier.phone ?? 'Chưa có SĐT'),
                        trailing: const Icon(Icons.edit, size: 20),
                        onTap: () {
                          context.push('/suppliers/edit/${supplier.id}', extra: supplier);
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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/suppliers/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
