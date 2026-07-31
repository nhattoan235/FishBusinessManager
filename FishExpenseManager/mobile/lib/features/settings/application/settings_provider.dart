import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../domain/repositories/backup_repository.dart';
import '../infrastructure/repositories/local_backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalBackupRepository(db);
});

final appSettingsProvider = StreamProvider<AppSettingData>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchSettings();
});
