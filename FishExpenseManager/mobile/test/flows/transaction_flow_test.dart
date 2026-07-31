import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/transactions/application/transaction_provider.dart';

import '../utils/test_utils.dart';

void main() {
  group('Transaction Flow Tests', () {
    test('Ghi nhận khoản thu thành công (BR-601)', () async {
      final container = createTestProviderContainer();
      
      final recordTransactionUseCase = container.read(recordTransactionUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // Đếm giao dịch ban đầu (Nên là 0)
      var transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final initialCount = transactions.length;

      // 1. Thực hiện ghi thu
      await recordTransactionUseCase.execute(
        amount: 200000,
        isIncome: true,
        type: 'Bán lẻ',
        description: 'Khách vãng lai mua',
        date: DateTime.now(),
      );

      // 2. Xác minh
      transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(transactions.length, initialCount + 1);
      final latestTx = transactions.first; // DESC order usually, let's verify
      // In Drift queries, usually ordered by date DESC. Let's find the specific one.
      final ourTx = transactions.firstWhere((t) => t.amount == 200000 && t.type == 'Bán lẻ');
      expect(ourTx.isIncome, true);
      expect(ourTx.description, 'Khách vãng lai mua');
    });

    test('Ghi nhận khoản chi thành công (BR-601)', () async {
      final container = createTestProviderContainer();
      
      final recordTransactionUseCase = container.read(recordTransactionUseCaseProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);

      // 1. Thực hiện ghi chi
      await recordTransactionUseCase.execute(
        amount: 50000,
        isIncome: false,
        type: 'Xăng xe',
        description: 'Đổ xăng đi giao hàng',
        date: DateTime.now(),
      );

      // 2. Xác minh
      final transactions = await transactionRepo.getTransactions(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      final ourTx = transactions.firstWhere((t) => t.amount == 50000 && t.type == 'Xăng xe');
      expect(ourTx.isIncome, false);
      expect(ourTx.description, 'Đổ xăng đi giao hàng');
    });

    test('Ghi nhận giao dịch thất bại - Số tiền âm hoặc bằng 0 (BR-603)', () async {
      final container = createTestProviderContainer();
      
      final recordTransactionUseCase = container.read(recordTransactionUseCaseProvider);

      await expectLater(
        recordTransactionUseCase.execute(
          amount: 0,
          isIncome: true,
          type: 'Khác',
          description: '',
          date: DateTime.now(),
        ),
        throwsException,
      );

      await expectLater(
        recordTransactionUseCase.execute(
          amount: -10000,
          isIncome: false,
          type: 'Khác',
          description: '',
          date: DateTime.now(),
        ),
        throwsException,
      );
    });
  });
}
