import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/debt_dao.dart';
import '../../domain/entities/debt_item_entity.dart';

abstract class DebtRepository {
  Stream<List<DebtItemEntity>> watchDebtList();

  Future<void> collectDebt({
    required int customerId,
    required double amount,
    required DateTime date,
  });
}

class DebtRepositoryImpl implements DebtRepository {
  final AppDatabase _db;
  final DebtDao _debtDao;

  DebtRepositoryImpl(this._db) : _debtDao = _db.debtDao;

  @override
  Stream<List<DebtItemEntity>> watchDebtList() {
    // Join customerBalances with customers
    final query = _db.select(_db.customerBalances).join([
      innerJoin(_db.customers,
          _db.customers.id.equalsExp(_db.customerBalances.customerId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final balance = row.readTable(_db.customerBalances);
        final customer = row.readTable(_db.customers);
        return DebtItemEntity(
          customerId: customer.id,
          customerName: customer.name,
          customerPhone: customer.phone,
          // DB stores as int (đồng), entity expects double
          balance: balance.currentDebt.toDouble(),
          lastUpdatedAt: balance.updatedAt,
        );
      }).toList();
    });
  }

  @override
  Future<void> collectDebt({
    required int customerId,
    required double amount,
    required DateTime date,
  }) async {
    await _db.transaction(() async {
      // 1. Validate amount > 0 (BR-503)
      if (amount <= 0) {
        throw Exception('Số tiền thu phải lớn hơn 0 (BR-503)');
      }

      // 2. Get current debt
      final existingBalances = await (_db.select(_db.customerBalances)
            ..where((t) => t.customerId.equals(customerId)))
          .get();
      if (existingBalances.isEmpty) {
        throw Exception('Khách hàng không có nợ');
      }
      final current = existingBalances.first;
      if (current.currentDebt < amount.toInt()) {
        throw Exception('Số tiền thu không được lớn hơn số tiền nợ (BR-503)');
      }

      // 2. Decrease Customer Balance
      await (_db.update(_db.customerBalances)
            ..where((t) => t.customerId.equals(customerId)))
          .write(CustomerBalancesCompanion(
        currentDebt: Value(current.currentDebt - amount.toInt()),
        updatedAt: Value(DateTime.now()),
      ));

      // 3. Record Debt Transaction (decrease)
      await _debtDao.insertDebtTransaction(DebtTransactionsCompanion.insert(
        customerId: customerId,
        changeType: 'decrease',
        amount: amount.toInt(),
        note: const Value('Thu tiền nợ'),
        createdAt: Value(DateTime.now()),
      ));

      // 4. Record Income Transaction
      await _db.transactionDao.insertTransaction(TransactionsCompanion.insert(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount.toInt(),
        isIncome: const Value(true),
        type: 'Thu nợ',
        description: const Value('Thu nợ khách hàng'),
        date: date,
        createdAt: Value(DateTime.now()),
      ));
    });
  }
}
