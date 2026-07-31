import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSettingData> getSettings() => select(appSettings).getSingle();
  
  Stream<AppSettingData> watchSettings() => select(appSettings).watchSingle();
  
  Future<bool> updateSettings(AppSettingsCompanion settings) => update(appSettings).replace(settings);
}
