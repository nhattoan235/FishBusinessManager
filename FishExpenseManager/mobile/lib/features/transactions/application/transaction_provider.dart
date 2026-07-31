import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/transaction_repository.dart';
import '../infrastructure/repositories/transaction_repository_impl.dart';
import '../domain/entities/transaction_entity.dart';
import 'use_cases/record_transaction_use_case.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db.transactionDao);
});

final transactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions();
});

final recordTransactionUseCaseProvider = Provider<RecordTransactionUseCase>((ref) {
  return RecordTransactionUseCase(ref.watch(transactionRepositoryProvider));
});
