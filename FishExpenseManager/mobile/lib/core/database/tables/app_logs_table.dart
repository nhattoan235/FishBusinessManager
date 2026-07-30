import 'package:drift/drift.dart';

@DataClassName('AppLogData')
class AppLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get module => text()();
  TextColumn get action => text()();
  IntColumn get recordId => integer().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
