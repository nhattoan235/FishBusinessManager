import 'package:drift/drift.dart';

@DataClassName('DatabaseInfoData')
class DatabaseInfo extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get schemaVersion => integer()();
  IntColumn get databaseVersion => integer()();
  DateTimeColumn get lastBackup => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
