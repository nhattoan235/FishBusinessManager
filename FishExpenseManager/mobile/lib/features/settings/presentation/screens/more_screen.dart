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
          const ListTile(
            leading: Icon(Icons.inventory_2),
            title: Text('Kho hàng'),
            subtitle: Text('Giai đoạn 3'),
          ),
          const ListTile(
            leading: Icon(Icons.category),
            title: Text('Sản phẩm & Đơn vị'),
            subtitle: Text('Giai đoạn 3'),
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
          const ListTile(
            leading: Icon(Icons.backup),
            title: Text('Sao lưu & Khôi phục'),
            subtitle: Text('Giai đoạn 3'),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Cài đặt'),
            subtitle: Text('Giai đoạn 3'),
          ),
        ],
      ),
    );
  }
}
