class BackupEntry {
  final String fileName;
  final String path;
  final int fileSize;
  final DateTime createdAt;
  final String storage;
  final String? remoteId;

  const BackupEntry({
    required this.fileName,
    required this.path,
    required this.fileSize,
    required this.createdAt,
    required this.storage,
    this.remoteId,
  });
}
