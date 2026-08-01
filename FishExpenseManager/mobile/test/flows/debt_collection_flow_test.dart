// ignore_for_file: avoid_print
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:fish_business_manager/features/debts/application/debt_provider.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';

import '../utils/test_utils.dart';

void main() {
  group('Debt Collection Flow Tests — UC-011 Ghi nhận Thu nợ Khách hàng', () {
    // ─── Helper: Tạo sẵn khách hàng có nợ ────────────────────────────────────
    Future<Map<String, dynamic>> setupCustomerWithDebt(
      ProviderContainer container, {
      required String uuid,
      required String name,
      required double totalAmount,
      required double paidAmount,
    }) async {
      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: uuid,
          name: name,
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(
          productId: 1, difference: totalAmount / 25000 + 10);

      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        saleDate: DateTime.now(),
        items: [
          SaleItemEntity(
            productId: 1,
            quantity: totalAmount / 25000,
            unitPrice: 25000,
            subTotal: totalAmount,
          ),
        ],
      );

      return {
        'customerId': customerId,
        'debtAmount': totalAmount - paidAmount,
      };
    }

    // ─── Happy Path ───────────────────────────────────────────────────────────

    test('Thu nợ thành công - Trả một phần (BR-702, BR-501)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final debtRepo = container.read(debtRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // Setup: Nợ 400k
      final setupResult = await setupCustomerWithDebt(
        container,
        uuid: 'test-uuid-debt-1',
        name: 'Khách hàng Nợ A',
        totalAmount: 500000,
        paidAmount: 100000,
      );
      final customerId = setupResult['customerId'] as int;
      final debtAmount = setupResult['debtAmount'] as double;
      expect(debtAmount, 400000);

      // Đếm transaction ban đầu
      var transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final initialTransactionCount = transactions.length;
      // Có đúng 1 transaction từ lúc bán (paidAmount = 100k)
      expect(initialTransactionCount, 1);

      // Thu nợ 150k
      await debtRepo.collectDebt(
        customerId: customerId,
        amount: 150000,
        date: DateTime.now(),
      );

      // Nợ giảm còn 250k
      final debtList = await debtRepo.watchDebtList().first;
      final customerDebt =
          debtList.firstWhere((e) => e.customerId == customerId);
      expect(customerDebt.balance, 250000,
          reason: '400k - 150k = 250k còn lại');

      // Transaction tăng thêm 1 (thu nợ)
      transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, initialTransactionCount + 1);

      final collectTx = transactions.firstWhere((t) => t.type == 'Thu nợ');
      expect(collectTx.amount, 150000);
      expect(collectTx.isIncome, true,
          reason: 'Thu nợ là giao dịch thu (income)');
    });

    test('Thu nợ thành công - Trả hết toàn bộ nợ (BR-501, BR-703)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final debtRepo = container.read(debtRepositoryProvider);

      // Setup: Nợ 200k
      final setupResult = await setupCustomerWithDebt(
        container,
        uuid: 'test-uuid-debt-3',
        name: 'Khách hàng Nợ C',
        totalAmount: 200000,
        paidAmount: 0,
      );
      final customerId = setupResult['customerId'] as int;
      final debtAmount = setupResult['debtAmount'] as double;
      expect(debtAmount, 200000);

      // Thu đúng bằng số nợ
      await debtRepo.collectDebt(
        customerId: customerId,
        amount: 200000,
        date: DateTime.now(),
      );

      // Nợ = 0
      final debtList = await debtRepo.watchDebtList().first;
      final customerBalance =
          debtList.firstWhere((e) => e.customerId == customerId);
      expect(customerBalance.balance, 0,
          reason: 'Trả hết nợ, balance phải = 0');
    });

    test(
        'Thu nợ thành công - Lịch sử debt_transactions có bản ghi decrease (BR-702)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final debtRepo = container.read(debtRepositoryProvider);
      final db = container.read(databaseProvider);

      // Setup: Nợ 300k
      final setupResult = await setupCustomerWithDebt(
        container,
        uuid: 'test-uuid-debt-4',
        name: 'Khách hàng Nợ D',
        totalAmount: 300000,
        paidAmount: 0,
      );
      final customerId = setupResult['customerId'] as int;

      // Thu 100k
      await debtRepo.collectDebt(
        customerId: customerId,
        amount: 100000,
        date: DateTime.now(),
      );

      // Kiểm tra bảng debt_transactions có bản ghi decrease
      final allDebtTx = await db.select(db.debtTransactions).get();
      final decreaseTx = allDebtTx
          .where(
              (tx) => tx.customerId == customerId && tx.changeType == 'decrease')
          .toList();

      expect(decreaseTx.isNotEmpty, true,
          reason:
              'Phải có bản ghi decrease trong debt_transactions (BR-702)');
      expect(decreaseTx.first.amount, 100000);
    });

    // ─── Validation / Error Cases ─────────────────────────────────────────────

    test('Thu nợ thất bại - Vượt quá số nợ (BR-503)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final debtRepo = container.read(debtRepositoryProvider);

      // Setup: Nợ 200k
      final setupResult = await setupCustomerWithDebt(
        container,
        uuid: 'test-uuid-debt-2',
        name: 'Khách hàng Nợ B',
        totalAmount: 200000,
        paidAmount: 0,
      );
      final customerId = setupResult['customerId'] as int;

      // Cố thu 300k > 200k → phải ném lỗi
      await expectLater(
        debtRepo.collectDebt(
          customerId: customerId,
          amount: 300000, // Vi phạm BR-503
          date: DateTime.now(),
        ),
        throwsException,
      );

      // Nợ không thay đổi
      final debtList = await debtRepo.watchDebtList().first;
      final customerBalance =
          debtList.firstWhere((e) => e.customerId == customerId);
      expect(customerBalance.balance, 200000,
          reason: 'Nợ phải nguyên vẹn sau khi rollback');
    });

    test('Thu nợ thất bại - Số tiền = 0 (BR-503)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final debtRepo = container.read(debtRepositoryProvider);

      final setupResult = await setupCustomerWithDebt(
        container,
        uuid: 'test-uuid-debt-5',
        name: 'Khách hàng Nợ E',
        totalAmount: 100000,
        paidAmount: 0,
      );
      final customerId = setupResult['customerId'] as int;

      // Thu 0 đồng → phải lỗi
      await expectLater(
        debtRepo.collectDebt(
          customerId: customerId,
          amount: 0, // Không hợp lệ theo BR-503
          date: DateTime.now(),
        ),
        throwsException,
      );
    });
  });
}
