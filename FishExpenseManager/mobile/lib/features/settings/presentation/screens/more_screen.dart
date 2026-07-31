import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chức năng khác')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Kho hàng'),
            subtitle: const Text('Quản lý nhập xuất tồn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/inventory'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Sản phẩm & Đơn vị'),
            subtitle: const Text('Danh mục hàng hóa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/products'),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Nhà cung cấp'),
            subtitle: const Text('Nguồn nhập hàng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/suppliers'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Khách hàng'),
            subtitle: const Text('Quản lý thông tin khách hàng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/customers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            subtitle: const Text('Sao lưu và tùy chỉnh'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
