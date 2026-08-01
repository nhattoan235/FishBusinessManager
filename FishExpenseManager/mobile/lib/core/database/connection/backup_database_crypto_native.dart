import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite;

Future<void> encryptPlaintextDatabase({
  required String sourcePath,
  required String destinationPath,
  required String encryptionKey,
}) async {
  final destination = File(destinationPath);
  if (await destination.exists()) await destination.delete();

  final database = sqlite.sqlite3.open(sourcePath);
  try {
    final escaped = destinationPath.replaceAll("'", "''");
    database.execute(
      "ATTACH DATABASE '$escaped' AS encrypted KEY \"x'$encryptionKey'\"",
    );
    database.select("SELECT sqlcipher_export('encrypted')");
    database.execute('DETACH DATABASE encrypted');
  } finally {
    database.dispose();
  }

  final probe = sqlite.sqlite3.open(destinationPath);
  try {
    probe.execute("PRAGMA key = \"x'$encryptionKey'\"");
    if (probe.select('PRAGMA cipher_version').isEmpty) {
      throw StateError('Không thể xác nhận SQLCipher cho file khôi phục.');
    }
    probe.select('PRAGMA integrity_check');
  } finally {
    probe.dispose();
  }
}
