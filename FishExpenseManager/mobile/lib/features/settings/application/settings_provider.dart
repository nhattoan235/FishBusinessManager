import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../domain/repositories/backup_repository.dart';
import '../infrastructure/repositories/local_backup_repository.dart';
import '../domain/entities/backup_entry.dart';
import '../infrastructure/services/auto_backup_coordinator.dart';
import '../infrastructure/services/cloud_backup_coordinator.dart';
import '../infrastructure/services/google_drive_backup_service.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalBackupRepository(
    db,
    ref.watch(databaseEncryptionKeyProvider),
  );
});

final localBackupRepositoryProvider = Provider<LocalBackupRepository>((ref) {
  return ref.watch(backupRepositoryProvider) as LocalBackupRepository;
});

final googleDriveBackupServiceProvider =
    Provider<GoogleDriveBackupService>((ref) {
  return GoogleDriveBackupService();
});

final cloudBackupCoordinatorProvider = Provider<CloudBackupCoordinator>((ref) {
  return CloudBackupCoordinator(
    ref.watch(databaseProvider),
    ref.watch(googleDriveBackupServiceProvider),
  );
});

final autoBackupCoordinatorProvider = Provider<AutoBackupCoordinator>((ref) {
  final coordinator = AutoBackupCoordinator(
    ref.watch(databaseProvider),
    ref.watch(localBackupRepositoryProvider),
    ref.watch(cloudBackupCoordinatorProvider),
  )..initialize();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final localBackupsProvider = FutureProvider<List<BackupEntry>>((ref) {
  return ref.watch(backupRepositoryProvider).listLocalBackups();
});

final appSettingsProvider = StreamProvider<AppSettingData>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchSettings();
});

/// Tests and unsupported embedders can disable platform background plugins.
final automaticBackupEnabledProvider = Provider<bool>((ref) => true);
