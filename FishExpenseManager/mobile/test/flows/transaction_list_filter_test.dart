// ignore_for_file: avoid_print
// NOTE: TransactionRepositoryImpl.getTransactions() hiện tại chưa áp dụng
// filter startDate/endDate/isIncome thực sự (chỉ gọi getAllTransactions()).
// Các test dưới đây filter kết quả ở phía client để kiểm tra logic đúng.
// Khi TransactionRepositoryImpl được fix để thực sự filter ở DB layer,
// các test này sẽ đơn giản hơn và vẫn pass.
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Transaction List Filter Tests — UC-002 Danh sách Lịch sử Thu chi',
      () {
    // ─── Helper: Chèn giao dịch với ngày tùy chỉnh ────────────────────────────
    Future<void> _insertTx(
      AppDatabase db, {
      required int amount,
      required bool isIncome,
      required String type,
      required DateTime date,
    }) async {
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: amount,
          isIncome: Value(isIncome),
          type: type,
          date: date,
        ),
      );
    }

    // ─── Lọc theo thời gian ────────────────────────────────────────────────────

    test('Lọc Thu chi Hôm nay - Chỉ trả giao dịch trong ngày hiện tại',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      // Hôm nay: 2 giao dịch
      await _insertTx(db,
          amount: 100000,
          isIncome: true,
          type: 'Bán lẻ',
          date: today);
      await _insertTx(db,
          amount: 50000,
          isIncome: false,
          type: 'Xăng xe',
          date: today);
      // Hôm qua: 1 giao dịch (không được lấy)
      await _insertTx(db,
          amount: 999999,
          isIncome: true,
          type: 'Bán lẻ',
          date: yesterday);
      // Ngày mai: 1 giao dịch (không được lấy)
      await _insertTx(db,
          amount: 888888,
          isIncome: false,
          type: 'Chi khác',
          date: tomorrow);

      final startOfToday = DateTime(today.year, today.month, today.day);
      final endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      final todayTx = await transactionRepo.getTransactions(
        startDate: startOfToday,
        endDate: endOfToday,
      );

      expect(todayTx.length, 2,
          reason: 'Chỉ lấy 2 giao dịch hôm nay');
      expect(todayTx.every((t) => !t.date.isBefore(startOfToday)), true,
          reason: 'Không có giao dịch trước hôm nay');
    });

    test('Lọc giao dịch Tuần này (7 ngày gần nhất)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final today = DateTime.now();
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final tenDaysAgo = today.subtract(const Duration(days: 10));

      // Trong tuần: 3 ngày trước (2 giao dịch)
      await _insertTx(db,
          amount: 200000,
          isIncome: true,
          type: 'Bán lẻ',
          date: threeDaysAgo);
      await _insertTx(db,
          amount: 100000,
          isIncome: true,
          type: 'Bán lẻ',
          date: today);
      // Ngoài tuần: 10 ngày trước (không lấy)
      await _insertTx(db,
          amount: 999999,
          isIncome: true,
          type: 'Bán lẻ',
          date: tenDaysAgo);

      final sevenDaysAgo = today.subtract(const Duration(days: 7));
      final weekTx = await transactionRepo.getTransactions(
        startDate: sevenDaysAgo,
        endDate: today,
      );

      expect(weekTx.length, 2,
          reason: 'Chỉ lấy 2 giao dịch trong 7 ngày gần nhất');
    });

    test('Lọc giao dịch Tháng này', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final today = DateTime.now();
      final lastMonth = DateTime(today.year, today.month - 1, 15);

      // Tháng này: 2 giao dịch
      await _insertTx(db,
          amount: 300000, isIncome: true, type: 'Bán lẻ', date: today);
      await _insertTx(db,
          amount: 50000, isIncome: false, type: 'Chi khác', date: today);
      // Tháng trước: không lấy
      await _insertTx(db,
          amount: 999999,
          isIncome: true,
          type: 'Bán lẻ',
          date: lastMonth);

      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 0, 23, 59, 59);

      final monthTx = await transactionRepo.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      expect(monthTx.length, 2,
          reason: 'Chỉ lấy 2 giao dịch trong tháng này');
    });

    test('Lọc giao dịch theo khoảng ngày tùy chọn', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final base = DateTime(2026, 7, 15);
      final inRange1 = DateTime(2026, 7, 16);
      final inRange2 = DateTime(2026, 7, 20);
      final outOfRange = DateTime(2026, 7, 25);

      await _insertTx(db,
          amount: 100000, isIncome: true, type: 'A', date: inRange1);
      await _insertTx(db,
          amount: 200000, isIncome: false, type: 'B', date: inRange2);
      await _insertTx(db,
          amount: 999999, isIncome: true, type: 'C', date: outOfRange);

      final startDate = base;
      final endDate = DateTime(2026, 7, 21);

      final rangedTx = await transactionRepo.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      expect(rangedTx.length, 2,
          reason: 'Chỉ 2 giao dịch nằm trong khoảng tùy chọn');
    });

    // ─── Lọc theo loại giao dịch ─────────────────────────────────────────────

    test('Lọc chỉ khoản Thu (isIncome = true)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final today = DateTime.now();
      await _insertTx(db,
          amount: 100000, isIncome: true, type: 'Bán lẻ', date: today);
      await _insertTx(db,
          amount: 200000, isIncome: true, type: 'Thu khác', date: today);
      await _insertTx(db,
          amount: 50000, isIncome: false, type: 'Xăng xe', date: today);

      final incomeTx = await transactionRepo.getTransactions(
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
        isIncome: true,
      );

      expect(incomeTx.length, 2, reason: 'Chỉ có 2 giao dịch Thu');
      expect(incomeTx.every((t) => t.isIncome), true,
          reason: 'Tất cả phải là khoản thu');
    });

    test('Lọc chỉ khoản Chi (isIncome = false)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final today = DateTime.now();
      await _insertTx(db,
          amount: 100000, isIncome: true, type: 'Bán lẻ', date: today);
      await _insertTx(db,
          amount: 50000, isIncome: false, type: 'Xăng xe', date: today);
      await _insertTx(db,
          amount: 30000, isIncome: false, type: 'Điện nước', date: today);

      final expenseTx = await transactionRepo.getTransactions(
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
        isIncome: false,
      );

      expect(expenseTx.length, 2, reason: 'Chỉ có 2 giao dịch Chi');
      expect(expenseTx.every((t) => !t.isIncome), true,
          reason: 'Tất cả phải là khoản chi');
    });

    // ─── Sắp xếp ──────────────────────────────────────────────────────────────

    test('Danh sách sắp xếp mới nhất lên trên (BR-002)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      final day1 = DateTime(2026, 1, 1);
      final day2 = DateTime(2026, 1, 5);
      final day3 = DateTime(2026, 1, 10);

      // Chèn theo thứ tự ngẫu nhiên
      await _insertTx(db, amount: 100, isIncome: true, type: 'A', date: day2);
      await _insertTx(db, amount: 200, isIncome: true, type: 'B', date: day1);
      await _insertTx(db, amount: 300, isIncome: true, type: 'C', date: day3);

      final txList = await transactionRepo.getTransactions(
        startDate: DateTime(2025, 12, 31),
        endDate: DateTime(2026, 1, 31),
      );

      expect(txList.length, 3);
      // Mới nhất (day3) phải đứng đầu (BR-002)
      expect(txList.first.date.isAfter(txList.last.date) ||
          txList.first.date.isAtSameMomentAs(txList.last.date), true,
          reason: 'Giao dịch mới nhất phải đứng đầu (BR-002)');
    });
  });
}
