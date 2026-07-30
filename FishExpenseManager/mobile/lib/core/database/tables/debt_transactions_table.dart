import 'package:drift/drift.dart';
import 'customers_table.dart';
import 'sale_documents_table.dart';

@DataClassName('DebtTransactionData')
class DebtTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get saleDocumentId => integer().nullable().references(SaleDocuments, #id)();
  TextColumn get changeType => text()(); // increase / decrease
  IntColumn get amount => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
