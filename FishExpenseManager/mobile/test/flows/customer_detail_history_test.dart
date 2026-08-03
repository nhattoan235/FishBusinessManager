import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:fish_business_manager/features/debts/application/debt_provider.dart';
import 'package:fish_business_manager/features/debts/presentation/screens/debt_detail_screen.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  test('Lịch sử mua và thanh toán được lọc đúng theo từng khách hàng',
      () async {
    final container = createTestProviderContainer();
    addTearDown(container.dispose);

    final customers = container.read(customerRepositoryProvider);
    final inventory = container.read(inventoryRepositoryProvider);
    final sales = container.read(createSaleUseCaseProvider);
    final debts = container.read(debtRepositoryProvider);

    final firstCustomerId = await customers.addCustomer(
      CustomerEntity(
        uuid: 'customer-history-1',
        name: 'Khách thứ nhất',
        createdAt: DateTime(2026, 8, 2),
      ),
    );
    final secondCustomerId = await customers.addCustomer(
      CustomerEntity(
        uuid: 'customer-history-2',
        name: 'Khách thứ hai',
        createdAt: DateTime(2026, 8, 2),
      ),
    );

    await inventory.adjustInventory(productId: 1, difference: 100);
    await sales.execute(
      customerId: firstCustomerId,
      totalAmount: 100000,
      paidAmount: 40000,
      saleDate: DateTime(2026, 8, 2, 8),
      items: const [
        SaleItemEntity(
          productId: 1,
          quantity: 2,
          unitPrice: 50000,
          subTotal: 100000,
        ),
      ],
    );
    await debts.collectDebt(
      customerId: firstCustomerId,
      amount: 20000,
      date: DateTime(2026, 8, 2, 9),
    );
    await sales.execute(
      customerId: secondCustomerId,
      totalAmount: 30000,
      paidAmount: 30000,
      saleDate: DateTime(2026, 8, 2, 10),
      items: const [
        SaleItemEntity(
          productId: 1,
          quantity: 1,
          unitPrice: 30000,
          subTotal: 30000,
        ),
      ],
    );

    final first =
        await container.read(customerHistoryProvider(firstCustomerId).future);
    final second =
        await container.read(customerHistoryProvider(secondCustomerId).future);

    expect(first.purchases, hasLength(1));
    expect(first.payments.map((payment) => payment.amount),
        containsAll(<int>[40000, 20000]));
    expect(first.payments.map((payment) => payment.source),
        containsAll(<String>['Thanh toán khi mua hàng', 'Thu nợ']));

    expect(second.purchases, hasLength(1));
    expect(second.payments, hasLength(1));
    expect(second.payments.single.amount, 30000);

    final debtDetails =
        await container.read(debtDetailProvider(firstCustomerId).future);
    expect(debtDetails, hasLength(1));
    expect(
      debtDetails.single.debtAmount,
      40000,
      reason: 'Còn nợ phải trừ lần thu nợ 20.000 khỏi nợ phiếu 60.000',
    );
  });
}
