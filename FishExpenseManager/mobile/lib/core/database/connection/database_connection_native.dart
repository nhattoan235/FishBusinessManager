import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

const _databaseFileName = 'fish_business_manager_db.sqlite';

QueryExecutor openDatabaseConnection({String? encryptionKey}) {
  if (encryptionKey == null || encryptionKey.length != 64) {
    throw StateError('Không thể mở cơ sở dữ liệu vì khóa mã hóa không hợp lệ.');
  }
  if (Platform.isAndroid) {
    _configureSqlCipherForIsolate();
  }

  return LazyDatabase(() async {
    final documents = await getApplicationDocumentsDirectory();
    final file = File(p.join(documents.path, _databaseFileName));
    await _encryptLegacyDatabaseIfNeeded(file, encryptionKey);

    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        database.execute("PRAGMA key = \"x'$encryptionKey'\"");
        database.execute('PRAGMA cipher_memory_security = ON');
        database.execute('PRAGMA foreign_keys = ON');
      },
      isolateSetup: _configureSqlCipherForIsolate,
    );
  });
}

void _configureSqlCipherForIsolate() {
  if (Platform.isAndroid) {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }
}

Future<void> _encryptLegacyDatabaseIfNeeded(File file, String key) async {
  if (!await file.exists() || await file.length() == 0) return;

  sqlite.Database? probe;
  try {
    probe = sqlite.sqlite3.open(file.path);
    probe.select('SELECT count(*) FROM sqlite_master');
  } catch (_) {
    probe?.dispose();
    _verifyEncryptedDatabase(file, key);
    return;
  }

  final encrypted = File('${file.path}.encrypted');
  if (await encrypted.exists()) await encrypted.delete();
  try {
    probe.execute('PRAGMA wal_checkpoint(FULL)');
    final encryptedPath = encrypted.path.replaceAll("'", "''");
    probe.execute(
        "ATTACH DATABASE '$encryptedPath' AS encrypted KEY \"x'$key'\"");
    probe.select("SELECT sqlcipher_export('encrypted')");
    probe.execute('DETACH DATABASE encrypted');
  } finally {
    probe.dispose();
  }

  _verifyEncryptedDatabase(encrypted, key);
  final legacy = File('${file.path}.plaintext_migration');
  if (await legacy.exists()) await legacy.delete();
  await file.rename(legacy.path);
  try {
    await encrypted.rename(file.path);
    await legacy.delete();
  } catch (_) {
    if (!await file.exists() && await legacy.exists()) {
      await legacy.rename(file.path);
    }
    rethrow;
  }
}

void _verifyEncryptedDatabase(File file, String key) {
  final database = sqlite.sqlite3.open(file.path);
  try {
    database.execute("PRAGMA key = \"x'$key'\"");
    final cipherVersion = database.select('PRAGMA cipher_version');
    if (cipherVersion.isEmpty) {
      throw StateError('Bản SQLite hiện tại không có SQLCipher.');
    }
    database.select('SELECT count(*) FROM sqlite_master');
  } finally {
    database.dispose();
  }
}
