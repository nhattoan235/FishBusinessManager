import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/transaction_dao.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDao _dao;

  TransactionRepositoryImpl(this._dao);

  @override
  Future<List<TransactionEntity>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
  }) async {
    final query = _dao.attachedDatabase.select(_dao.attachedDatabase.transactions);

    query
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..where((t) {
        Expression<bool> condition = const Constant(true);
        if (startDate != null) {
          condition = condition & t.date.isBiggerOrEqualValue(startDate);
        }
        if (endDate != null) {
          condition = condition & t.date.isSmallerOrEqualValue(endDate);
        }
        if (isIncome != null) {
          condition = condition & t.isIncome.equals(isIncome);
        }
        return condition;
      });

    final data = await query.get();
    return data.map(_mapToEntity).toList();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return _dao.watchAllTransactions().map(
          (list) => list.map(_mapToEntity).toList(),
        );
  }

  @override
  Future<void> recordTransaction(TransactionEntity transaction) async {
    await _dao.insertTransaction(TransactionsCompanion.insert(
      uuid: transaction.uuid,
      amount: transaction.amount.toInt(),
      isIncome: Value(transaction.isIncome),
      type: transaction.type,
      description: Value(transaction.description),
      date: transaction.date,
      referenceId: Value(transaction.referenceId),
      createdAt: Value(transaction.createdAt),
    ));
  }

  TransactionEntity _mapToEntity(TransactionData data) {
    return TransactionEntity(
      id: data.id,
      uuid: data.uuid,
      amount: data.amount.toDouble(),
      isIncome: data.isIncome,
      type: data.type,
      description: data.description ?? '',
      date: data.date,
      referenceId: data.referenceId,
      createdAt: data.createdAt,
    );
  }
}
