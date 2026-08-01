// ignore_for_file: avoid_print
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/debts/application/debt_provider.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Dashboard Metrics Tests — UC-001 Xem Trang chủ (Dashboard)', () {
    // ─── Tính toán chỉ số ─────────────────────────────────────────────────────

    test(
        'Tính Tiền hiện có = Tổng thu - Tổng chi (AD-001)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);

      // Thêm 3 giao dịch thu: 500k + 300k = 800k
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: 500000,
          isIncome: const Value(true),
          type: 'Thu khác',
          date: DateTime.now(),
        ),
      );
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: 300000,
          isIncome: const Value(true),
          type: 'Bán hàng',
          date: DateTime.now(),
        ),
      );
      // Thêm 1 giao dịch chi: 200k
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: 200000,
          isIncome: const Value(false),
          type: 'Chi khác',
          date: DateTime.now(),
        ),
      );

      // Tính Tiền hiện có = SUM(income) - SUM(expense)
      final allTx = await db.select(db.transactions).get();
      final totalIncome =
          allTx.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
      final totalExpense = allTx
          .where((t) => !t.isIncome)
          .fold(0, (sum, t) => sum + t.amount);
      final currentBalance = totalIncome - totalExpense;

      expect(totalIncome, 800000,
          reason: '500k + 300k = 800k tổng thu');
      expect(totalExpense, 200000,
          reason: '200k tổng chi');
      expect(currentBalance, 600000,
          reason: 'Tiền hiện có = 800k - 200k = 600k');
    });

    test('Tính Thu hôm nay - Chỉ lấy giao dịch trong ngày hiện tại', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final transactionRepo = container.read(transactionRepositoryProvider);
      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Giao dịch hôm nay: 200k
      await recordTransactionUseCase.execute(
        amount: 200000,
        isIncome: true,
        type: 'Bán lẻ',
        description: 'Hôm nay',
        date: today,
      );

      // Giao dịch hôm qua: 500k (không được tính)
      final db = container.read(databaseProvider);
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: 500000,
          isIncome: const Value(true),
          type: 'Bán lẻ',
          date: yesterday,
        ),
      );

      // Lọc Thu hôm nay
      final startOfToday =
          DateTime(today.year, today.month, today.day);
      final endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      final todayTransactions = await transactionRepo.getTransactions(
        startDate: startOfToday,
        endDate: endOfToday,
        isIncome: true,
      );

      final todayIncome =
          todayTransactions.fold(0.0, (sum, t) => sum + t.amount);
      expect(todayIncome, 200000,
          reason: 'Thu hôm nay chỉ là 200k, không tính hôm qua');
    });

    test('Tính Chi hôm nay - Chỉ lấy giao dịch chi trong ngày hiện tại',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final transactionRepo = container.read(transactionRepositoryProvider);
      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);

      final today = DateTime.now();

      // Chi hôm nay: 80k
      await recordTransactionUseCase.execute(
        amount: 80000,
        isIncome: false,
        type: 'Xăng xe',
        description: 'Chi hôm nay',
        date: today,
      );

      final startOfToday = DateTime(today.year, today.month, today.day);
      final endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      final todayExpenses = await transactionRepo.getTransactions(
        startDate: startOfToday,
        endDate: endOfToday,
        isIncome: false,
      );

      final todayExpense =
          todayExpenses.fold(0.0, (sum, t) => sum + t.amount);
      expect(todayExpense, 80000,
          reason: 'Chi hôm nay = 80k');
    });

    test('Tính Khách còn nợ - Tổng dư nợ từ customer_balances', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);
      final debtRepo = container.read(debtRepositoryProvider);

      // Tạo 2 khách hàng có nợ: 100k và 200k
      final cust1Id = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'dash-cust-1',
          name: 'Khách Nợ 1',
          createdAt: DateTime.now(),
        ),
      );
      final cust2Id = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'dash-cust-2',
          name: 'Khách Nợ 2',
          createdAt: DateTime.now(),
        ),
      );

      await inventoryRepo.adjustInventory(productId: 1, difference: 200);

      await createSaleUseCase.execute(
        customerId: cust1Id,
        totalAmount: 100000,
        paidAmount: 0,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 4,
            unitPrice: 25000,
            subTotal: 100000,
          ),
        ],
      );
      await createSaleUseCase.execute(
        customerId: cust2Id,
        totalAmount: 200000,
        paidAmount: 0,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 8,
            unitPrice: 25000,
            subTotal: 200000,
          ),
        ],
      );

      // Tổng công nợ = 100k + 200k = 300k
      final debtList = await debtRepo.watchDebtList().first;
      final totalDebt = debtList.fold(0.0, (sum, d) => sum + d.balance);
      expect(totalDebt, 300000,
          reason: 'Tổng khách còn nợ = 300k');

      // Số lượng khách có nợ > 0
      final debtCustomers =
          debtList.where((d) => d.balance > 0).toList();
      expect(debtCustomers.length, 2,
          reason: 'Có 2 khách đang nợ');
    });

    test('Tính Tồn kho - Tổng từ Ledger inventory_entries', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Nhập 100, xuất 30
      await inventoryRepo.adjustInventory(productId: 1, difference: 100);
      await inventoryRepo.adjustInventory(productId: 1, difference: -30);

      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final totalStock =
          inventorySummary.fold(0.0, (sum, e) => sum + e.currentStock);
      expect(totalStock, 70,
          reason: 'Tổng tồn kho = 100 - 30 = 70 (AD-001)');
    });
  });
}
