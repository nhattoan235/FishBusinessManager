import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/settings/infrastructure/repositories/local_backup_repository.dart';
import '../database/app_database.dart';
import '../security/database_encryption_service.dart';

const _uniqueTask = 'fish_business_periodic_backup';
const _taskName = 'automaticBackup';

@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    AppDatabase? database;
    try {
      final key = await DatabaseEncryptionService().getOrCreateKey();
      database = AppDatabase(encryptionKey: key);
      final settings = await database.settingsDao.getSettings();
      if (!settings.autoBackup) return true;

      final info = await (database.select(database.databaseInfo)
            ..where((row) => row.id.equals(1)))
          .getSingleOrNull();
      final lastBackup = info?.lastBackup;
      final intervalElapsed = lastBackup == null ||
          DateTime.now().difference(lastBackup) >=
              Duration(hours: settings.backupInterval);
      if (intervalElapsed || settings.transactionsSinceBackup > 0) {
        await LocalBackupRepository(database, key)
            .createBackup(backupType: 'scheduled');
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      await database?.close();
    }
  });
}

Future<void> initializeBackgroundBackup() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await Workmanager().initialize(backupCallbackDispatcher);
}

Future<void> scheduleBackgroundBackup(Duration frequency) async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await Workmanager().registerPeriodicTask(
    _uniqueTask,
    _taskName,
    frequency: frequency < const Duration(minutes: 15)
        ? const Duration(minutes: 15)
        : frequency,
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

Future<void> cancelBackgroundBackup() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await Workmanager().cancelByUniqueName(_uniqueTask);
}
