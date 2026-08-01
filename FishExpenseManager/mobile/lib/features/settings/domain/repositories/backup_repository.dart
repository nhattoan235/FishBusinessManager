import '../entities/backup_entry.dart';

abstract class BackupRepository {
  /// Khởi tạo quá trình tạo file backup database.
  /// Trả về đường dẫn của file backup hoặc null nếu người dùng hủy.
  Future<String?> createBackup({String backupType = 'manual'});

  /// Khôi phục dữ liệu từ file backup.
  /// Nếu thành công, sẽ báo cho app restart hoặc reload database.
  Future<bool> restoreBackup();

  Future<bool> restoreFromPath(String path);

  Future<List<BackupEntry>> listLocalBackups();
}
