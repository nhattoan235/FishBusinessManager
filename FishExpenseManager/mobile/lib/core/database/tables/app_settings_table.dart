import 'package:drift/drift.dart';

@DataClassName('AppSettingData')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get fontScale => real().withDefault(const Constant(1.0))();
  TextColumn get theme => text().withDefault(const Constant('light'))();
  BoolColumn get autoBackup => boolean().withDefault(const Constant(true))();
  IntColumn get backupInterval => integer().withDefault(const Constant(24))();
  IntColumn get keepBackupDays => integer().withDefault(const Constant(30))();
  IntColumn get backupTransactionThreshold =>
      integer().withDefault(const Constant(20))();
  IntColumn get transactionsSinceBackup =>
      integer().withDefault(const Constant(0))();
  BoolColumn get useGoogleDrive =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get useBoldFont => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
