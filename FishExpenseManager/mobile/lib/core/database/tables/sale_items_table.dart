import 'package:drift/drift.dart';
import 'sale_documents_table.dart';
import 'products_table.dart';

@DataClassName('SaleItemData')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleDocumentId => integer().references(SaleDocuments, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  RealColumn get quantity => real()();
  IntColumn get unitPrice => integer()();
  IntColumn get totalPrice => integer()();
  TextColumn get note => text().nullable()();
}
