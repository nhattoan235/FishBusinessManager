// ignore_for_file: avoid_print
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
  group('Sale Flow Tests — UC-005 Tạo phiếu Bán hàng', () {
    // ─── Happy Path ───────────────────────────────────────────────────────────

    test('Bán hàng thành công - Khách trả đủ tiền (BR-404)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);
      final debtRepo = container.read(debtRepositoryProvider);

      // 1. Tạo khách hàng
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-1',
          name: 'Khách hàng A',
          createdAt: DateTime.now(),
        ),
      );

      // 2. Nhập kho 100kg sản phẩm 1 (seed mặc định: Chứng nước)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
        note: 'Kho nhập ban đầu',
      );

      // 3. Bán 10kg, 15k/kg → Total: 150k, Trả đủ 150k
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

      // 4. Xác minh: Tồn kho giảm 10 (còn 90)
      final inventoryStream = inventoryRepo.watchInventorySummary();
      final inventorySummary = await inventoryStream.first;
      final product1Stock =
          inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(product1Stock.currentStock, 90, reason: '100 - 10 = 90');

      // 5. Xác minh: Thu tiền được ghi nhận (transaction income)
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, 1);
      expect(transactions.first.amount, 150000);
      expect(transactions.first.isIncome, true);
      expect(transactions.first.type, 'Bán hàng');

      // 6. Xác minh: Không có nợ (hoặc nợ = 0)
      final balances = await debtRepo.watchDebtList().first;
      if (balances.isNotEmpty) {
        final found = balances.where((e) => e.customerId == customerId);
        if (found.isNotEmpty) {
          expect(found.first.balance, 0,
              reason: 'Khách trả đủ nên không có nợ');
        }
      }
    });

    test('Bán hàng thành công - Khách nợ một phần (BR-404)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-2',
          name: 'Khách hàng B',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
      );

      // Bán 20kg, 15k/kg → Total: 300k, Trả 100k, Nợ 200k
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

      // Tồn kho: 100 - 20 = 80
      final inventorySummary =
          await inventoryRepo.watchInventorySummary().first;
      expect(
          inventorySummary.firstWhere((e) => e.product.id == 1).currentStock,
          80);

      // Thu tiền: 100k
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, 1);
      expect(transactions.first.amount, 100000);

      // Công nợ: 200k
      final balances = await debtRepo.watchDebtList().first;
      final customerBalance =
          balances.firstWhere((e) => e.customerId == customerId);
      expect(customerBalance.balance, 200000,
          reason: 'Tổng nợ phải đúng là 200k');
    });

    test('Bán hàng thành công - Nợ hoàn toàn (paidAmount = 0)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-6',
          name: 'Khách hàng Nợ Toàn Bộ',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(productId: 1, difference: 50);

      // Bán 10kg, giá 25k, không trả đồng nào
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 250000,
        paidAmount: 0,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 10,
            unitPrice: 25000,
            subTotal: 250000,
          ),
        ],
      );

      // Không có transaction thu tiền nào
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.isEmpty, true,
          reason: 'Không trả tiền nên không có transaction thu');

      // Toàn bộ là nợ: 250k
      final balances = await debtRepo.watchDebtList().first;
      final customerBalance =
          balances.firstWhere((e) => e.customerId == customerId);
      expect(customerBalance.balance, 250000,
          reason: 'Nợ bằng tổng tiền bán');
    });

    // ─── Validation / Error Cases ─────────────────────────────────────────────

    test('Bán hàng thất bại - Vượt tồn kho (BR-802)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-3',
          name: 'Khách hàng C',
          createdAt: DateTime.now(),
        ),
      );

      // Tồn kho chỉ có 5
      await inventoryRepo.adjustInventory(productId: 1, difference: 5);

      // Bán 10 → thất bại vì vượt tồn kho
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

      // Tồn kho không thay đổi (rollback)
      final inventorySummary =
          await inventoryRepo.watchInventorySummary().first;
      expect(inventorySummary.firstWhere((e) => e.product.id == 1).currentStock,
          5,
          reason: 'Tồn kho phải nguyên vẹn sau khi rollback');
    });

    test('Bán hàng thất bại - Đơn hàng không có sản phẩm (BR-401)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-4',
          name: 'Khách hàng D',
          createdAt: DateTime.now(),
        ),
      );

      // Không có sản phẩm nào trong items → phải ném lỗi
      await expectLater(
        createSaleUseCase.execute(
          customerId: customerId,
          totalAmount: 0,
          paidAmount: 0,
          saleDate: DateTime.now(),
          items: const [], // BR-401: phải có ít nhất 1 sản phẩm
        ),
        throwsException,
      );
    });

    test(
        'Bán hàng thất bại - Số tiền trả vượt tổng tiền (BR-402/BR-403)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'test-uuid-sale-5',
          name: 'Khách hàng E',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(productId: 1, difference: 100);

      // paidAmount (200k) > totalAmount (100k) → không hợp lệ
      await expectLater(
        createSaleUseCase.execute(
          customerId: customerId,
          totalAmount: 100000,
          paidAmount: 200000, // Vượt tổng tiền
          saleDate: DateTime.now(),
          items: [
            const SaleItemEntity(
              productId: 1,
              quantity: 10,
              unitPrice: 10000,
              subTotal: 100000,
            ),
          ],
        ),
        throwsException,
      );
    });
  });
}
