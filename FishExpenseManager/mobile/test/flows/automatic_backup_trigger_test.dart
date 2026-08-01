import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  test('Mỗi giao dịch làm tăng bộ đếm sao lưu tự động', () async {
    final container = createTestProviderContainer();
    addTearDown(container.dispose);
    final database = container.read(databaseProvider);

    await database.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        uuid: const Uuid().v4(),
        amount: 100000,
        type: 'Thu khác',
        date: DateTime.now(),
      ),
    );

    final settings = await database.settingsDao.getSettings();
    expect(settings.transactionsSinceBackup, 1);
    expect(settings.backupTransactionThreshold, 20);
  });
}
