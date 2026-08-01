import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../../app/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import 'google_drive_backup_service.dart';

class CloudBackupCoordinator {
  final AppDatabase _db;
  final GoogleDriveBackupService _drive;
  bool _isProcessing = false;

  CloudBackupCoordinator(this._db, this._drive);

  Future<CloudBackupUploadResult> enqueueAndUpload(
    String localPath, {
    bool promptIfNecessary = false,
  }) async {
    final logId = await _db.into(_db.backupLogs).insert(
          BackupLogsCompanion.insert(
            fileName: p.basename(localPath),
            fileSize: 0,
            backupType: 'upload',
            storage: 'drive',
            status: 'pending',
            checksum: '',
            appVersion: AppConstants.appVersion,
            dbVersion: _db.schemaVersion,
          ),
        );
    return _uploadLog(
      logId,
      localPath,
      promptIfNecessary: promptIfNecessary,
    );
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final pending = await (_db.select(_db.backupLogs)
            ..where((row) =>
                row.storage.equals('drive') & row.status.equals('pending'))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();
      final localDirectory = await _localBackupDirectory();
      for (final log in pending) {
        await _uploadLog(
          log.id,
          p.join(localDirectory, log.fileName),
          promptIfNecessary: false,
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<CloudBackupUploadResult> _uploadLog(
    int logId,
    String localPath, {
    required bool promptIfNecessary,
  }) async {
    try {
      await _drive.upload(localPath, promptIfNecessary: promptIfNecessary);
      await (_db.update(_db.backupLogs)..where((row) => row.id.equals(logId)))
          .write(const BackupLogsCompanion(status: Value('completed')));
      return const CloudBackupUploadResult.uploaded();
    } catch (error, stackTrace) {
      // Pending is intentional: connectivity changes and future foreground
      // launches retry it. Local data is never removed on upload failure.
      debugPrint('Google Drive backup upload failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return CloudBackupUploadResult.pending(error);
    }
  }

  Future<String> _localBackupDirectory() async {
    final rows = await _db.customSelect('PRAGMA database_list').get();
    final main = rows.firstWhere((row) => row.read<String>('name') == 'main');
    return p.join(p.dirname(main.read<String>('file')), 'backups');
  }
}

class CloudBackupUploadResult {
  final bool isUploaded;
  final Object? error;

  const CloudBackupUploadResult.uploaded()
      : isUploaded = true,
        error = null;

  const CloudBackupUploadResult.pending(this.error) : isUploaded = false;
}
