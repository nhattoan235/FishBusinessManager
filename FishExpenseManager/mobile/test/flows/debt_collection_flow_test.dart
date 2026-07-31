import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:fish_business_manager/features/debts/application/debt_provider.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';

import '../utils/test_utils.dart';

void main() {
  group('Debt Collection Flow Tests', () {
    test('Thu nợ thành công (BR-702, BR-501)', () async {
      final container = createTestProviderContainer();
      
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // 1. Tạo khách hàng
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-debt-1',
          name: 'Khách hàng Nợ',
          createdAt: DateTime.now(),
        ),
      );

      // 2. Nhập kho để có hàng bán
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
      );

      // 3. Tạo một đơn hàng nợ (Tổng 500k, trả 100k -> Nợ 400k)
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 500000,
        paidAmount: 100000,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 20,
            unitPrice: 25000,
            subTotal: 500000,
          ),
        ],
      );

      // Kiểm tra nợ ban đầu là 400k
      var debtList = await debtRepo.watchDebtList().first;
      var customerDebt = debtList.firstWhere((e) => e.customerId == customerId);
      expect(customerDebt.balance, 400000);

      // Đếm số lượng transaction ban đầu (1 transaction từ sale)
      var transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final initialTransactionCount = transactions.length;
      expect(initialTransactionCount, 1);

      // 4. Thực hiện thu nợ 150k
      await debtRepo.collectDebt(
        customerId: customerId,
        amount: 150000,
        date: DateTime.now(),
      );

      // 5. Xác minh
      // Công nợ giảm xuống còn 250k
      debtList = await debtRepo.watchDebtList().first;
      customerDebt = debtList.firstWhere((e) => e.customerId == customerId);
      expect(customerDebt.balance, 250000);

      // Transaction tăng thêm 1 (Thu nợ)
      transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, initialTransactionCount + 1);
      final collectTx = transactions.last;
      expect(collectTx.amount, 150000);
      expect(collectTx.isIncome, true);
      expect(collectTx.type, 'Thu nợ');
    });

    test('Thu nợ thất bại - Vượt quá số nợ (BR-503)', () async {
      final container = createTestProviderContainer();
      
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-debt-2',
          name: 'Khách hàng Nợ 2',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
      );

      // Bán nợ 200k
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 200000,
        paidAmount: 0,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 10,
            unitPrice: 20000,
            subTotal: 200000,
          ),
        ],
      );

      // Cố gắng thu 300k (Lớn hơn 200k)
      await expectLater(
        debtRepo.collectDebt(
          customerId: customerId,
          amount: 300000,
          date: DateTime.now(),
        ),
        throwsException, // Số tiền thu không được lớn hơn số tiền nợ
      );
    });
  });
}
