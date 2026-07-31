import 'package:drift/drift.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get type => text()(); // income / expense / collect_debt / other
  BoolColumn get isIncome => boolean().withDefault(const Constant(true))();
  IntColumn get amount => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
