abstract class BackupRepository {
  /// Khởi tạo quá trình tạo file backup database.
  /// Trả về đường dẫn của file backup hoặc null nếu người dùng hủy.
  Future<String?> createBackup();

  /// Khôi phục dữ liệu từ file backup.
  /// Nếu thành công, sẽ báo cho app restart hoặc reload database.
  Future<bool> restoreBackup();
}
