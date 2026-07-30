import 'package:drift/drift.dart';

@DataClassName('BackupLogData')
class BackupLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();
  TextColumn get backupType => text()(); // manual / scheduled
  TextColumn get storage => text()(); // local / drive
  TextColumn get status => text()(); // pending / completed / failed
  TextColumn get checksum => text()();
  TextColumn get appVersion => text()();
  IntColumn get dbVersion => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
