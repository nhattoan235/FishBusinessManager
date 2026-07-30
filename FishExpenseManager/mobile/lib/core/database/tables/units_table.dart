import 'package:drift/drift.dart';

@DataClassName('UnitData')
class Units extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
