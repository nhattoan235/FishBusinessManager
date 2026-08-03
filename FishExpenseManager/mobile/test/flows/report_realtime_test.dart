import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:fish_business_manager/features/reports/application/report_provider.dart';

import '../utils/test_utils.dart';

void main() {
  test('Báo cáo ngày tự cập nhật và cộng đúng thu chi khi có giao dịch mới',
      () async {
    final container = createTestProviderContainer();
    addTearDown(container.dispose);
    final db = container.read(databaseProvider);
    final now = DateTime.now();

    container.read(selectedYearProvider.notifier).state = now.year;
    container.read(selectedMonthProvider.notifier).state = now.month;

    final updated = Completer<void>();
    final subscription = container.listen(
      dailyStatsProvider,
      (previous, next) {
        next.when(
          data: (stats) {
            final today = stats[now.day - 1];
            if (!updated.isCompleted &&
                today.income == 125000 &&
                today.expense == 30000) {
              updated.complete();
            }
          },
          loading: () {},
          error: (error, stack) {
            if (!updated.isCompleted) updated.completeError(error, stack);
          },
        );
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await db.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        uuid: 'report-income',
        amount: 125000,
        type: 'Bán hàng',
        isIncome: const Value(true),
        date: now,
      ),
    );
    await db.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        uuid: 'report-expense',
        amount: 30000,
        type: 'Chi phí',
        isIncome: const Value(false),
        date: now,
      ),
    );

    await updated.future.timeout(const Duration(seconds: 3));

    final monthly = await container.read(monthlyStatsProvider.future);
    expect(monthly[now.month - 1].totalIncome, 125000);
    expect(monthly[now.month - 1].totalExpense, 30000);
  });
}
