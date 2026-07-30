import 'package:drift/drift.dart';
import 'product_categories_table.dart';
import 'units_table.dart';

@DataClassName('ProductData')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  IntColumn get categoryId => integer().references(ProductCategories, #id)();
  IntColumn get unitId => integer().references(Units, #id)();
  TextColumn get name => text()();
  IntColumn get defaultPrice => integer().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
