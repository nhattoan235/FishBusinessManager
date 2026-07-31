import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/debt_transactions_table.dart';
import '../tables/customer_balances_table.dart';

part 'debt_dao.g.dart';

@DriftAccessor(tables: [DebtTransactions, CustomerBalances])
class DebtDao extends DatabaseAccessor<AppDatabase> with _$DebtDaoMixin {
  DebtDao(super.db);

  Future<List<DebtTransactionData>> getAllDebtTransactions() => select(debtTransactions).get();
  
  Stream<List<DebtTransactionData>> watchAllDebtTransactions() => select(debtTransactions).watch();
  
  Future<int> insertDebtTransaction(DebtTransactionsCompanion transaction) => into(debtTransactions).insert(transaction);
}
