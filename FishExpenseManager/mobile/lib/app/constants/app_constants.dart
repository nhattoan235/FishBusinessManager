abstract class AppConstants {
  static const String appName = 'Fish Business Manager';
  static const String appVersion = '1.0.0';
  static const int databaseVersion = 3;
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  // Currency
  static const String currencySymbol = 'đ';
  static const String currencyLocale = 'vi_VN';

  // Seed Data Defaults
  static const String defaultProductName = 'Chứng nước';
  static const String defaultUnitName = 'Kilogram';
  static const String defaultUnitSymbol = 'kg';
  static const String defaultCategoryName = 'Chứng nước';

  // Local Storage & Backup
  static const int maxLocalBackups = 10;
  static const int maxDriveBackups = 30;
  static const int defaultBackupTransactionThreshold = 20;
  static const String backupFilePrefix = 'fish_business_backup_';
  static const String backupExtension = '.zip';
}
