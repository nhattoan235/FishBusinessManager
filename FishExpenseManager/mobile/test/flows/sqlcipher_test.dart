import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test(
    'SQLite native bundle Android có SQLCipher',
    () {
      final database = sqlite3.openInMemory();
      try {
        final result = database.select('PRAGMA cipher_version');
        expect(result, isNotEmpty);
        expect(result.first.values.first.toString(), isNotEmpty);
      } finally {
        database.dispose();
      }
    },
    skip: !Platform.isAndroid ? 'Cần chạy trên thiết bị Android' : false,
  );
}
