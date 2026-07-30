import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
      ),
      body: const Center(
        child: Text(
          'Fish Business Manager - Trang chủ',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
