import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<TransactionData>> getAllTransactions() => select(transactions).get();
  
  Stream<List<TransactionData>> watchAllTransactions() => select(transactions).watch();
  
  Future<int> insertTransaction(TransactionsCompanion transaction) => into(transactions).insert(transaction);
}
