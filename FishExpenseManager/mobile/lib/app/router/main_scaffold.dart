import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 28),
            selectedIcon: Icon(Icons.home, size: 28, color: AppColors.primary),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_outlined, size: 28),
            selectedIcon: Icon(Icons.swap_vert, size: 28, color: AppColors.primary),
            label: 'Thu chi',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, size: 28),
            selectedIcon: Icon(Icons.shopping_cart, size: 28, color: AppColors.primary),
            label: 'Bán hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined, size: 28),
            selectedIcon: Icon(Icons.account_balance_wallet, size: 28, color: AppColors.primary),
            label: 'Công nợ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_outlined, size: 28),
            selectedIcon: Icon(Icons.menu, size: 28, color: AppColors.primary),
            label: 'Khác',
          ),
        ],
      ),
    );
  }
}
