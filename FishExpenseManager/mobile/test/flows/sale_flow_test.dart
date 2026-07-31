import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:fish_business_manager/features/debts/application/debt_provider.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Sale Flow Tests', () {
    test('Bán hàng thành công - Khách trả đủ', () async {
      final container = createTestProviderContainer();
      
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);
      final debtRepo = container.read(debtRepositoryProvider);

      // 1. Setup Customer
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-1',
          name: 'Khách hàng A',
          createdAt: DateTime.now(),
        ),
      );

      // 2. Setup Inventory (Add 100kg of product 1)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
        note: 'Kho nhập ban đầu',
      );

      // 3. Execute Sale (Bán 10kg, 15k/kg -> Total: 150k, Trả đủ 150k)
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 150000,
        paidAmount: 150000,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 10,
            unitPrice: 15000,
            subTotal: 150000,
          ),
        ],
      );

      // 4. Verification
      // Check Inventory
      final inventoryStream = inventoryRepo.watchInventorySummary();
      final inventorySummary = await inventoryStream.first;
      final product1Stock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(product1Stock.currentStock, 90); // 100 - 10

      // Check Transactions (Income should be recorded)
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, 1);
      expect(transactions.first.amount, 150000);
      expect(transactions.first.type, 'Bán hàng'); // Depends on your enum to string

      // Check Debts
      final balances = await debtRepo.watchDebtList().first;
      // Khách trả đủ nên balance có thể không được tạo hoặc bằng 0
      if (balances.isNotEmpty) {
        final customerBalance = balances.firstWhere((e) => e.customerId == customerId, orElse: () => throw Exception('Không tìm thấy'));
        expect(customerBalance.balance, 0);
      }
    });

    test('Bán hàng thành công - Khách nợ một phần', () async {
      final container = createTestProviderContainer();
      
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-2',
          name: 'Khách hàng B',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
      );

      // Bán 20kg, 15k/kg -> Total: 300k, Trả 100k, Nợ 200k
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 300000,
        paidAmount: 100000,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 20,
            unitPrice: 15000,
            subTotal: 300000,
          ),
        ],
      );

      // Verification
      // Tồn kho: 100 - 20 = 80
      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      expect(inventorySummary.firstWhere((e) => e.product.id == 1).currentStock, 80);

      // Thu tiền: 100k
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, 1);
      expect(transactions.first.amount, 100000);

      // Công nợ: 200k
      final balances = await debtRepo.watchDebtList().first;
      final customerBalance = balances.firstWhere((e) => e.customerId == customerId);
      expect(customerBalance.balance, 200000);
    });
    
    test('Bán hàng thất bại - Bán lố tồn kho (BR-802)', () async {
      final container = createTestProviderContainer();
      
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-3',
          name: 'Khách hàng C',
          createdAt: DateTime.now(),
        ),
      );

      // Tồn kho ban đầu: 5
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 5,
      );

      // Bán 10kg -> Thất bại
      await expectLater(
        createSaleUseCase.execute(
          customerId: customerId,
          totalAmount: 150000,
          paidAmount: 0,
          saleDate: DateTime.now(),
          items: [
            const SaleItemEntity(
              productId: 1,
              quantity: 10,
              unitPrice: 15000,
              subTotal: 150000,
            ),
          ],
        ),
        throwsException,
      );
    });
  });
}
