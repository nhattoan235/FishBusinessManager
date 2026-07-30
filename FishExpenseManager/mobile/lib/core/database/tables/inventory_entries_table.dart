import 'package:drift/drift.dart';
import 'products_table.dart';
import 'suppliers_table.dart';
import 'sale_documents_table.dart';

@DataClassName('InventoryEntryData')
class InventoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get entryType => text()(); // purchase / harvest / sale / adjustment
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  IntColumn get saleDocumentId => integer().nullable().references(SaleDocuments, #id)();
  RealColumn get quantity => real()(); // Always positive
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
