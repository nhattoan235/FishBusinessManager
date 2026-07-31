import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
  });
  
  Stream<List<TransactionEntity>> watchTransactions();
  
  Future<void> recordTransaction(TransactionEntity transaction);
}
