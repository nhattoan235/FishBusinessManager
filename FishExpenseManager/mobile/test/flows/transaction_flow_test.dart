// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';

import '../utils/test_utils.dart';

void main() {
  group('Transaction Flow Tests — UC-003 Thu tiền & UC-004 Chi tiền', () {
    // ─── UC-003: Thêm khoản Thu ───────────────────────────────────────────────

    test('Ghi nhận khoản thu thành công (BR-501, BR-603)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // Đếm giao dịch ban đầu
      var transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final initialCount = transactions.length;

      // Ghi thu 200k
      await recordTransactionUseCase.execute(
        amount: 200000,
        isIncome: true,
        type: 'Bán lẻ',
        description: 'Khách vãng lai mua',
        date: DateTime.now(),
      );

      // Xác minh
      transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, initialCount + 1);

      final ourTx =
          transactions.firstWhere((t) => t.amount == 200000 && t.type == 'Bán lẻ');
      expect(ourTx.isIncome, true, reason: 'Khoản thu phải là income');
      expect(ourTx.description, 'Khách vãng lai mua');
    });

    test('Ghi nhận khoản thu nhiều lần - Mỗi lần là bản ghi độc lập (BR-501)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // Ghi thu 2 lần
      await recordTransactionUseCase.execute(
        amount: 100000,
        isIncome: true,
        type: 'Bán lẻ',
        description: 'Lần 1',
        date: DateTime.now(),
      );
      await recordTransactionUseCase.execute(
        amount: 200000,
        isIncome: true,
        type: 'Bán lẻ',
        description: 'Lần 2',
        date: DateTime.now(),
      );

      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      // Mỗi lần tạo một bản ghi mới (không ghi đè)
      expect(transactions.length, 2,
          reason: 'Mỗi lần thu tạo 1 bản ghi riêng (BR-501)');
    });

    // ─── UC-004: Thêm khoản Chi ───────────────────────────────────────────────

    test('Ghi nhận khoản chi thành công (BR-601, BR-603)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      await recordTransactionUseCase.execute(
        amount: 50000,
        isIncome: false,
        type: 'Xăng xe',
        description: 'Đổ xăng đi giao hàng',
        date: DateTime.now(),
      );

      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final ourTx =
          transactions.firstWhere((t) => t.amount == 50000 && t.type == 'Xăng xe');
      expect(ourTx.isIncome, false, reason: 'Khoản chi không phải income');
      expect(ourTx.description, 'Đổ xăng đi giao hàng');
    });

    // ─── Validation / Error Cases ─────────────────────────────────────────────

    test('Ghi giao dịch thất bại - Số tiền = 0 (BR-603)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);

      await expectLater(
        recordTransactionUseCase.execute(
          amount: 0, // Vi phạm BR-603
          isIncome: true,
          type: 'Bán lẻ',
          description: '',
          date: DateTime.now(),
        ),
        throwsException,
      );
    });

    test('Ghi giao dịch thất bại - Số tiền âm (BR-603)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);

      await expectLater(
        recordTransactionUseCase.execute(
          amount: -10000, // Vi phạm BR-603
          isIncome: false,
          type: 'Chi khác',
          description: 'Test âm',
          date: DateTime.now(),
        ),
        throwsException,
      );
    });

    test('Ghi khoản chi thất bại - Loại giao dịch trống (BR-601)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final recordTransactionUseCase =
          container.read(recordTransactionUseCaseProvider);

      // BR-601: Khoản chi phải có Loại chi
      await expectLater(
        recordTransactionUseCase.execute(
          amount: 50000,
          isIncome: false,
          type: '', // Loại chi trống → vi phạm BR-601
          description: 'Mua thức ăn cá',
          date: DateTime.now(),
        ),
        throwsException,
      );
    });
  });
}
