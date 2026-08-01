import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/background_backup.dart';
import '../repositories/local_backup_repository.dart';
import 'cloud_backup_coordinator.dart';

class AutoBackupCoordinator {
  final AppDatabase _db;
  final LocalBackupRepository _local;
  final CloudBackupCoordinator _cloud;
  StreamSubscription<AppSettingData>? _settingsSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isBackingUp = false;

  AutoBackupCoordinator(this._db, this._local, this._cloud);

  void initialize() {
    _settingsSubscription ??=
        _db.settingsDao.watchSettings().listen((settings) {
      if (settings.autoBackup) {
        scheduleBackgroundBackup(Duration(hours: settings.backupInterval));
        if (settings.transactionsSinceBackup >=
            settings.backupTransactionThreshold) {
          backupIfDirty(reason: 'transaction_threshold');
        }
      } else {
        cancelBackgroundBackup();
      }
    });
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _cloud.processQueue();
      }
    });
    _cloud.processQueue();
  }

  Future<void> backupIfDirty({required String reason}) async {
    if (_isBackingUp) return;
    final settings = await _db.settingsDao.getSettings();
    if (!settings.autoBackup || settings.transactionsSinceBackup == 0) return;
    _isBackingUp = true;
    try {
      final path = await _local.createBackup(backupType: 'scheduled');
      if (path != null && settings.useGoogleDrive) {
        await _cloud.enqueueAndUpload(path);
      }
    } finally {
      _isBackingUp = false;
    }
  }

  void dispose() {
    _settingsSubscription?.cancel();
    _connectivitySubscription?.cancel();
  }
}
