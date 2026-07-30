import 'package:flutter/material.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách thu chi')),
      body: const Center(child: Text('Giai đoạn 2 — Màn hình Danh sách Thu chi')),
    );
  }
}
