import 'package:drift/drift.dart';
import 'customers_table.dart';

@DataClassName('SaleDocumentData')
class SaleDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get totalAmount => integer()();
  IntColumn get paidAmount => integer()();
  IntColumn get debtAmount => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get saleDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
