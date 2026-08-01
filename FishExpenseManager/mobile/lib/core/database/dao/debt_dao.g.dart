// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_dao.dart';

// ignore_for_file: type=lint
mixin _$DebtDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $SaleDocumentsTable get saleDocuments => attachedDatabase.saleDocuments;
  $DebtTransactionsTable get debtTransactions =>
      attachedDatabase.debtTransactions;
  $CustomerBalancesTable get customerBalances =>
      attachedDatabase.customerBalances;
  DebtDaoManager get managers => DebtDaoManager(this);
}

class DebtDaoManager {
  final _$DebtDaoMixin _db;
  DebtDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$SaleDocumentsTableTableManager get saleDocuments =>
      $$SaleDocumentsTableTableManager(_db.attachedDatabase, _db.saleDocuments);
  $$DebtTransactionsTableTableManager get debtTransactions =>
      $$DebtTransactionsTableTableManager(
          _db.attachedDatabase, _db.debtTransactions);
  $$CustomerBalancesTableTableManager get customerBalances =>
      $$CustomerBalancesTableTableManager(
          _db.attachedDatabase, _db.customerBalances);
}
