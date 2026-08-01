import 'package:fish_business_manager/app/theme/app_theme.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/products/application/product_provider.dart';
import 'package:fish_business_manager/features/products/domain/entities/product_entity.dart';
import 'package:fish_business_manager/features/sales/presentation/screens/sale_screen.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';
import 'package:fish_business_manager/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> useNarrowLargeTextScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(
    Widget home, {
    List<Override> overrides = const [],
    double systemTextScale = 1,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme(fontScale: 1.5, useBoldFont: true),
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(systemTextScale),
          ),
          child: home,
        ),
      ),
    );
  }

  testWidgets('bộ lọc thu chi không tràn khi chữ lớn', (tester) async {
    await useNarrowLargeTextScreen(tester);
    await tester.pumpWidget(
      app(
        const TransactionListScreen(),
        overrides: [
          transactionsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tháng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chọn sản phẩm không tràn khi chữ và tên dài', (tester) async {
    tester.view.physicalSize = const Size(240, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final product = ProductEntity(
      id: 1,
      uuid: 'product-1',
      categoryId: 1,
      unitId: 1,
      unit: const UnitEntity(
          id: 1, uuid: 'unit-1', name: 'Kilogram', symbol: 'kg'),
      name: 'Chứng nước loại đặc biệt tên rất dài',
      isActive: true,
      createdAt: DateTime(2026),
      currentStock: 123456,
    );

    await tester.pumpWidget(
      app(
        const SaleScreen(),
        systemTextScale: 2,
        overrides: [
          customersProvider.overrideWith((ref) => Stream.value(const [])),
          productListProvider.overrideWith((ref) => Stream.value([product])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Chứng nước loại đặc biệt'), findsOneWidget);
    expect(find.textContaining('Tồn kho: 123456 kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
