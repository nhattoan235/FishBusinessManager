import 'dart:async';
import 'package:flutter/foundation.dart';
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
    final data = await _dao.getAllTransactions();
    return data.map(_mapToEntity).toList();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    if (kIsWeb) {
      return Stream.value([
        TransactionEntity(
          uuid: 'mock-1',
          amount: 5000000,
          isIncome: true,
          type: 'Thu nợ',
          description: 'Mẫu: Khách trả nợ (Bạn đang chạy Web)',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        TransactionEntity(
          uuid: 'mock-2',
          amount: 1200000,
          isIncome: false,
          type: 'Chi phí',
          description: 'Mẫu: Trả tiền thức ăn cá (Bạn đang chạy Web)',
          date: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now(),
        )
      ]);
    }
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
