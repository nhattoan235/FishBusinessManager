import 'package:drift/drift.dart';
import 'sale_documents_table.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get transactionType => text()(); // income / expense / collect_debt / other
  IntColumn get amount => integer()();
  TextColumn get description => text().nullable()();
  IntColumn get saleDocumentId => integer().nullable().references(SaleDocuments, #id)();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
