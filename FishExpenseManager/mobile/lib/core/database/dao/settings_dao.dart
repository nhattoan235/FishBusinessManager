import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSettingData> getSettings() async {
    final settings = await select(appSettings).getSingleOrNull();
    if (settings != null) return settings;
    // Fallback if db not seeded
    return AppSettingData(
      id: 1,
      fontScale: 1.0,
      theme: 'light',
      autoBackup: false,
      backupInterval: 24,
      keepBackupDays: 30,
      useGoogleDrive: false,
      updatedAt: DateTime.now(),
      useBoldFont: false,
    );
  }
  
  Stream<AppSettingData> watchSettings() {
    return select(appSettings).watchSingleOrNull().map((settings) {
      if (settings != null) return settings;
      return AppSettingData(
        id: 1,
        fontScale: 1.0,
        theme: 'light',
        autoBackup: false,
        backupInterval: 24,
        keepBackupDays: 30,
        useGoogleDrive: false,
        updatedAt: DateTime.now(),
        useBoldFont: false,
      );
    });
  }
  
  Future<bool> updateSettings(AppSettingsCompanion settings) => update(appSettings).replace(settings);
}
