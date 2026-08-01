import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/customers/presentation/screens/add_customer_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/sales/presentation/screens/sale_screen.dart';
import '../../features/debts/presentation/screens/debt_list_screen.dart';
import '../../features/debts/presentation/screens/collect_debt_screen.dart';
import '../../features/debts/presentation/screens/debt_detail_screen.dart';
import '../../features/settings/presentation/screens/more_screen.dart';
import '../../features/reports/presentation/screens/report_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_list_screen.dart';
import '../../features/suppliers/presentation/screens/add_edit_supplier_screen.dart';
import '../../features/suppliers/domain/entities/supplier_entity.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/add_edit_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/inventory/presentation/screens/inventory_dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_screen.dart';
import '../../features/inventory/presentation/screens/inventory_history_screen.dart';
import 'main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddTransactionScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return TransactionDetailScreen(transactionId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (context, state) => const SaleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/debts',
                builder: (context, state) => const DebtListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      // Standalone routes (no bottom nav)
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/add',
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/customers/edit/:id',
        builder: (context, state) {
          // For edit, we'll push the AddCustomerScreen in edit mode
          // This would need customer data passed - simplified for now
          return const AddCustomerScreen();
        },
      ),
      GoRoute(
        path: '/debts/collect/:customerId',
        builder: (context, state) {
          final customerId = int.parse(state.pathParameters['customerId']!);
          return CollectDebtScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: '/debts/detail/:customerId',
        builder: (context, state) {
          final customerId = int.parse(state.pathParameters['customerId']!);
          return DebtDetailScreen(customerId: customerId);
        },
      ),
      // --- Phase 3 Routes ---
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SupplierListScreen(),
      ),
      GoRoute(
        path: '/suppliers/add',
        builder: (context, state) => const AddEditSupplierScreen(),
      ),
      GoRoute(
        path: '/suppliers/edit/:id',
        builder: (context, state) {
          final supplier = state.extra as SupplierEntity?;
          return AddEditSupplierScreen(supplier: supplier);
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/products/add',
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: '/products/edit/:id',
        builder: (context, state) {
          final product = state.extra as ProductEntity?;
          return AddEditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryDashboardScreen(),
      ),
      GoRoute(
        path: '/inventory/history',
        builder: (context, state) => const InventoryHistoryScreen(),
      ),
      GoRoute(
        path: '/inventory/adjust/:id',
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return InventoryAdjustmentScreen(product: product);
        },
      ),
    ],
  );
});
