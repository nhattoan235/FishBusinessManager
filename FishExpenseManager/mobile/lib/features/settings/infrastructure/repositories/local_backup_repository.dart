import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/connection/backup_database_crypto.dart';
import '../../domain/entities/backup_entry.dart';
import '../../domain/repositories/backup_repository.dart';

class LocalBackupRepository implements BackupRepository {
  static const _databaseName = 'database.sqlite';
  static const _metadataName = 'metadata.json';
  static const _checksumName = 'checksum.sha256';

  final AppDatabase _db;
  final String? _encryptionKey;
  bool _isRunning = false;

  LocalBackupRepository(this._db, this._encryptionKey);

  Future<Directory> _backupDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'backups'));
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _databaseFile() async {
    final documents = await getApplicationDocumentsDirectory();
    return File(p.join(documents.path, 'fish_business_manager_db.sqlite'));
  }

  @override
  Future<String?> createBackup({String backupType = 'manual'}) async {
    if (kIsWeb) throw UnsupportedError('Sao lưu không hỗ trợ trên Web.');
    if (_isRunning) throw StateError('Một tiến trình sao lưu đang chạy.');
    _isRunning = true;

    File? snapshot;
    try {
      final directory = await _backupDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${AppConstants.backupFilePrefix}$timestamp.zip';
      final output = File(p.join(directory.path, fileName));
      final temp = await getTemporaryDirectory();
      snapshot = File(p.join(temp.path, 'backup_snapshot_$timestamp.sqlite'));
      if (await snapshot.exists()) await snapshot.delete();

      // Export an unencrypted portable snapshot. The live database remains
      // SQLCipher-encrypted; this allows restore on a replacement device whose
      // secure-storage key is necessarily different.
      final escapedPath = snapshot.path.replaceAll("'", "''");
      await _db.customStatement(
        "ATTACH DATABASE '$escapedPath' AS backup_snapshot KEY ''",
      );
      try {
        await _db
            .customSelect("SELECT sqlcipher_export('backup_snapshot')")
            .get();
      } finally {
        await _db.customStatement('DETACH DATABASE backup_snapshot');
      }

      final databaseBytes = await snapshot.readAsBytes();
      final databaseChecksum = sha256.convert(databaseBytes).toString();
      final recordCount = await _recordCount();
      final metadata = jsonEncode({
        'appVersion': AppConstants.appVersion,
        'dbVersion': _db.schemaVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'records': recordCount,
      });

      final archive = Archive()
        ..addFile(ArchiveFile.bytes(_databaseName, databaseBytes))
        ..addFile(ArchiveFile.string(_metadataName, metadata))
        ..addFile(ArchiveFile.string(_checksumName, databaseChecksum));
      await output.writeAsBytes(ZipEncoder().encodeBytes(archive), flush: true);

      // Verify the archive can be decoded before it is accepted or old files
      // are removed (DP-004 / DP-005).
      await _validateArchive(output);
      final archiveChecksum =
          sha256.convert(await output.readAsBytes()).toString();
      await _db.into(_db.backupLogs).insert(
            BackupLogsCompanion.insert(
              fileName: fileName,
              fileSize: await output.length(),
              backupType: backupType,
              storage: 'local',
              status: 'completed',
              checksum: archiveChecksum,
              appVersion: AppConstants.appVersion,
              dbVersion: _db.schemaVersion,
            ),
          );
      await (_db.update(_db.appSettings)..where((row) => row.id.equals(1)))
          .write(
        const AppSettingsCompanion(transactionsSinceBackup: Value(0)),
      );
      await (_db.update(_db.databaseInfo)..where((row) => row.id.equals(1)))
          .write(
        DatabaseInfoCompanion(lastBackup: Value(DateTime.now())),
      );
      await _enforceLocalRetention(directory);
      return output.path;
    } catch (error) {
      await _logFailure(backupType, error);
      rethrow;
    } finally {
      _isRunning = false;
      if (snapshot != null && await snapshot.exists()) await snapshot.delete();
    }
  }

  Future<int> _recordCount() async {
    const tables = [
      'customers',
      'suppliers',
      'products',
      'sale_documents',
      'sale_items',
      'inventory_entries',
      'transactions',
      'customer_balances',
      'debt_transactions',
    ];
    var total = 0;
    for (final table in tables) {
      final row = await _db
          .customSelect('SELECT COUNT(*) AS amount FROM $table')
          .getSingle();
      total += row.read<int>('amount');
    }
    return total;
  }

  Future<void> _logFailure(String type, Object error) async {
    try {
      await _db.into(_db.backupLogs).insert(
            BackupLogsCompanion.insert(
              fileName: '',
              fileSize: 0,
              backupType: type,
              storage: 'local',
              status: 'failed',
              checksum: '',
              appVersion: AppConstants.appVersion,
              dbVersion: _db.schemaVersion,
            ),
          );
    } catch (_) {
      debugPrint('Không thể ghi backup log: $error');
    }
  }

  Future<void> _enforceLocalRetention(Directory directory) async {
    final files = await directory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.zip'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    for (final oldFile in files.skip(AppConstants.maxLocalBackups)) {
      await oldFile.delete();
    }
  }

  @override
  Future<List<BackupEntry>> listLocalBackups() async {
    if (kIsWeb) return const [];
    final directory = await _backupDirectory();
    final files = await directory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.zip'))
        .cast<File>()
        .toList();
    final entries = <BackupEntry>[];
    for (final file in files) {
      final stat = await file.stat();
      entries.add(BackupEntry(
        fileName: p.basename(file.path),
        path: file.path,
        fileSize: stat.size,
        createdAt: stat.modified,
        storage: 'local',
      ));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<bool> restoreBackup() async {
    if (kIsWeb) throw UnsupportedError('Khôi phục không hỗ trợ trên Web.');
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Chọn file sao lưu để khôi phục',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    final path = result?.files.single.path;
    if (path == null) return false;
    return restoreFromPath(path);
  }

  @override
  Future<bool> restoreFromPath(String path) async {
    if (_encryptionKey == null) {
      throw StateError('Không tìm thấy khóa mã hóa cơ sở dữ liệu.');
    }
    final archiveFile = File(path);
    final validated = await _validateArchive(archiveFile);
    await createBackup(backupType: 'safety_restore');

    final temporary = await getTemporaryDirectory();
    final plaintext = File(p.join(temporary.path, 'restore_plaintext.sqlite'));
    final encrypted = File(p.join(temporary.path, 'restore_encrypted.sqlite'));
    await plaintext.writeAsBytes(validated.databaseBytes, flush: true);
    await encryptPlaintextDatabase(
      sourcePath: plaintext.path,
      destinationPath: encrypted.path,
      encryptionKey: _encryptionKey,
    );

    final current = await _databaseFile();
    final rollback = File('${current.path}.restore_rollback');
    await _db.close();
    if (await rollback.exists()) await rollback.delete();
    await current.rename(rollback.path);
    try {
      await encrypted.rename(current.path);
      await rollback.delete();
      return true;
    } catch (_) {
      if (await current.exists()) await current.delete();
      if (await rollback.exists()) await rollback.rename(current.path);
      rethrow;
    } finally {
      if (await plaintext.exists()) await plaintext.delete();
      if (await encrypted.exists()) await encrypted.delete();
    }
  }

  Future<_ValidatedBackup> _validateArchive(File file) async {
    if (!await file.exists()) throw StateError('File sao lưu không tồn tại.');
    final archive =
        ZipDecoder().decodeBytes(await file.readAsBytes(), verify: true);
    ArchiveFile? databaseEntry;
    ArchiveFile? metadataEntry;
    ArchiveFile? checksumEntry;
    for (final entry in archive) {
      if (entry.name == _databaseName) databaseEntry = entry;
      if (entry.name == _metadataName) metadataEntry = entry;
      if (entry.name == _checksumName) checksumEntry = entry;
    }
    if (databaseEntry == null ||
        metadataEntry == null ||
        checksumEntry == null) {
      throw const FormatException('File sao lưu thiếu dữ liệu bắt buộc.');
    }
    final metadata = jsonDecode(utf8.decode(metadataEntry.readBytes()!))
        as Map<String, dynamic>;
    final version = metadata['dbVersion'] as int?;
    if (version == null || version > _db.schemaVersion) {
      throw StateError(
          'Cần cập nhật ứng dụng trước khi khôi phục bản sao lưu này.');
    }
    final databaseBytes = databaseEntry.readBytes()!;
    final expected = utf8.decode(checksumEntry.readBytes()!).trim();
    final actual = sha256.convert(databaseBytes).toString();
    if (actual != expected) {
      throw const FormatException('Checksum SHA-256 không hợp lệ.');
    }
    return _ValidatedBackup(databaseBytes);
  }
}

class _ValidatedBackup {
  final List<int> databaseBytes;
  const _ValidatedBackup(this.databaseBytes);
}
