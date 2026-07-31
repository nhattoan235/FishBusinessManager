import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../../../core/database/app_database.dart';

class LocalBackupRepository implements BackupRepository {
  final AppDatabase _db;

  LocalBackupRepository(this._db);

  Future<File> _getDbFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fish_business_manager_db.sqlite'));
    return file;
  }

  @override
  Future<String?> createBackup() async {
    if (kIsWeb) throw UnsupportedError('Backup is not supported on Web');

    try {
      final dbFile = await _getDbFile();
      if (!await dbFile.exists()) {
        throw Exception('Database file not found at ${dbFile.path}');
      }

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'fish_business_backup_$dateStr.sqlite';

      // Use FilePicker to let user pick save location
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Lưu file sao lưu',
        fileName: fileName,
        allowedExtensions: ['sqlite'],
        type: FileType.custom,
      );

      if (outputFile == null) {
        return null; // User canceled
      }

      await dbFile.copy(outputFile);
      return outputFile;
    } catch (e) {
      debugPrint('Backup error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreBackup() async {
    if (kIsWeb) throw UnsupportedError('Restore is not supported on Web');

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Chọn file sao lưu để khôi phục',
        type: FileType.custom,
        allowedExtensions: ['sqlite'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final backupPath = result.files.single.path;
      if (backupPath == null) return false;

      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('File sao lưu không tồn tại');
      }

      final dbFile = await _getDbFile();

      // Close db connection before overwriting
      await _db.close();

      await backupFile.copy(dbFile.path);

      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      rethrow;
    }
  }
}
