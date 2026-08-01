import 'dart:async';
import 'dart:io' as io;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../app/constants/app_constants.dart';
import '../../domain/entities/backup_entry.dart';

class GoogleDriveBackupService {
  static const _scopes = <String>[drive.DriveApi.driveFileScope];
  static const _folderName = 'Fish Business Manager Backups';
  static const _connectedEmailKey = 'google_drive_connected_email';
  static const _serverClientIdKey = 'google_drive_server_client_id';
  static const _storage = FlutterSecureStorage();

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  Future<void>? _initialization;
  GoogleSignInAccount? _account;

  String? get connectedEmail => _account?.email;

  Future<String?> _configuredServerClientId() async {
    if (io.Platform.isAndroid) {
      if (AppConstants.googleServerClientId.isNotEmpty) {
        return AppConstants.googleServerClientId;
      }
      if (AppConstants.googleClientId.isNotEmpty) {
        return AppConstants.googleClientId;
      }
      return _storage.read(key: _serverClientIdKey);
    }
    return AppConstants.googleServerClientId.isEmpty
        ? null
        : AppConstants.googleServerClientId;
  }

  Future<bool> isConfigured() async {
    final clientId = await _configuredServerClientId();
    return clientId != null && clientId.isNotEmpty;
  }

  Future<bool> saveServerClientId(String value) async {
    final clientId = value.trim();
    if (!clientId.endsWith('.apps.googleusercontent.com') ||
        clientId.contains(RegExp(r'\s'))) {
      throw const FormatException(
        'Client ID phải có đuôi .apps.googleusercontent.com và không chứa khoảng trắng.',
      );
    }
    final canConnectImmediately = _initialization == null;
    await _storage.write(key: _serverClientIdKey, value: clientId);
    return canConnectImmediately;
  }

  String get configurationHelp => io.Platform.isAndroid
      ? 'Dán Web Client ID có đuôi .apps.googleusercontent.com đã tạo trong '
          'Google Cloud. Giá trị này chỉ dùng để nhận diện ứng dụng, không phải '
          'Client secret hay mật khẩu Google.'
      : 'Google Drive chưa được cấu hình OAuth cho nền tảng này.';

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final serverClientId = await _configuredServerClientId();
    if (kDebugMode) {
      debugPrint('Google Drive OAuth serverClientId: $serverClientId');
    }
    await _signIn.initialize(
      clientId: io.Platform.isAndroid || AppConstants.googleClientId.isEmpty
          ? null
          : AppConstants.googleClientId,
      serverClientId: serverClientId,
    );
    _signIn.authenticationEvents.listen(
      (event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _account = event.user;
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _account = null;
        }
      },
      // authenticate() also completes with this error. Handling the stream
      // prevents a recoverable OAuth configuration error from becoming an
      // unhandled Flutter red screen.
      onError: (_) {},
    );
    final attempt = _signIn.attemptLightweightAuthentication();
    if (attempt != null) _account = await attempt;
  }

  Future<String?> restoreSession() async {
    await initialize();
    final email = _account?.email;
    if (email == null) await _storage.delete(key: _connectedEmailKey);
    return email;
  }

  Future<String> connect() async {
    if (!await isConfigured()) {
      throw GoogleDriveConfigurationException(configurationHelp);
    }
    await initialize();
    if (!_signIn.supportsAuthenticate()) {
      throw UnsupportedError(
          'Nền tảng này cần nút Google Sign-In chuyên dụng.');
    }
    try {
      _account = await _signIn.authenticate(scopeHint: _scopes);
    } on GoogleSignInException catch (error) {
      final details = error.toString();
      if (details.contains('28444') ||
          details.contains('Developer console is not set up correctly') ||
          error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        throw const GoogleDriveConfigurationException(
          'Google đã từ chối cấu hình OAuth. Hãy kiểm tra: Client ID đã nhập '
          'phải là Web application; Google Cloud phải có Android OAuth client '
          'với package com.fishbusinessmanager.app và đúng SHA-1 của APK; '
          'Google Drive API phải được bật. Sau khi sửa có thể cần chờ Google '
          'cập nhật cấu hình rồi thử lại.',
        );
      }
      rethrow;
    }
    await _authorization(promptIfNecessary: true);
    await _storage.write(key: _connectedEmailKey, value: _account!.email);
    return _account!.email;
  }

  Future<void> disconnect() async {
    await initialize();
    await _signIn.disconnect();
    _account = null;
    await _storage.delete(key: _connectedEmailKey);
  }

  Future<_DriveSession> _api({required bool promptIfNecessary}) async {
    final authorization = await _authorization(
      promptIfNecessary: promptIfNecessary,
    );
    final client = authorization.authClient(scopes: _scopes);
    return _DriveSession(drive.DriveApi(client), client);
  }

  Future<GoogleSignInClientAuthorization> _authorization({
    required bool promptIfNecessary,
  }) async {
    await initialize();
    final account = _account;
    if (account == null) {
      throw StateError('Chưa kết nối tài khoản Google Drive.');
    }
    final existing =
        await account.authorizationClient.authorizationForScopes(_scopes);
    if (existing != null) return existing;
    if (!promptIfNecessary) {
      throw StateError('Cần mở ứng dụng để cấp lại quyền Google Drive.');
    }
    return account.authorizationClient.authorizeScopes(_scopes);
  }

  Future<String> upload(String localPath,
      {bool promptIfNecessary = false}) async {
    final session = await _api(promptIfNecessary: promptIfNecessary);
    final api = session.api;
    try {
      final folderId = await _findOrCreateFolder(api);
      final local = io.File(localPath);
      if (!await local.exists()) {
        throw StateError('File sao lưu local không còn tồn tại.');
      }
      final metadata = drive.File()
        ..name = p.basename(localPath)
        ..parents = [folderId]
        ..mimeType = 'application/zip';
      final uploaded = await api.files.create(
        metadata,
        uploadMedia: drive.Media(local.openRead(), await local.length()),
        $fields: 'id,name,createdTime,size',
      );
      if (uploaded.id == null) {
        throw StateError('Google Drive không trả về mã file.');
      }
      await _enforceRetention(api, folderId);
      return uploaded.id!;
    } finally {
      session.close();
    }
  }

  Future<List<BackupEntry>> listBackups(
      {bool promptIfNecessary = false}) async {
    final session = await _api(promptIfNecessary: promptIfNecessary);
    final api = session.api;
    try {
      final folderId = await _findOrCreateFolder(api);
      final response = await api.files.list(
        q: "'$folderId' in parents and trashed = false",
        orderBy: 'createdTime desc',
        pageSize: AppConstants.maxDriveBackups,
        $fields: 'files(id,name,size,createdTime)',
      );
      return (response.files ?? const <drive.File>[])
          .where((file) => file.id != null && file.name != null)
          .map((file) => BackupEntry(
                fileName: file.name!,
                path: '',
                fileSize: int.tryParse(file.size ?? '') ?? 0,
                createdAt:
                    file.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0),
                storage: 'drive',
                remoteId: file.id,
              ))
          .toList();
    } finally {
      session.close();
    }
  }

  Future<String> download(BackupEntry entry) async {
    if (entry.remoteId == null) {
      throw ArgumentError('Bản sao lưu Drive thiếu ID.');
    }
    final session = await _api(promptIfNecessary: true);
    final api = session.api;
    try {
      final media = await api.files.get(
        entry.remoteId!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final temporary = await getTemporaryDirectory();
      final output = io.File(p.join(temporary.path, entry.fileName));
      final sink = output.openWrite();
      await media.stream.pipe(sink);
      return output.path;
    } finally {
      session.close();
    }
  }

  Future<String> _findOrCreateFolder(drive.DriveApi api) async {
    final escaped = _folderName.replaceAll("'", "\\'");
    final existing = await api.files.list(
      q: "name = '$escaped' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      pageSize: 1,
      $fields: 'files(id)',
    );
    final matches = existing.files ?? const <drive.File>[];
    final id = matches.isEmpty ? null : matches.first.id;
    if (id != null) return id;
    final folder = await api.files.create(
      drive.File()
        ..name = _folderName
        ..mimeType = 'application/vnd.google-apps.folder',
      $fields: 'id',
    );
    if (folder.id == null) {
      throw StateError('Không thể tạo thư mục Google Drive.');
    }
    return folder.id!;
  }

  Future<void> _enforceRetention(drive.DriveApi api, String folderId) async {
    final response = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      orderBy: 'createdTime desc',
      pageSize: 100,
      $fields: 'files(id,createdTime)',
    );
    final files = response.files ?? const <drive.File>[];
    for (final oldFile in files.skip(AppConstants.maxDriveBackups)) {
      if (oldFile.id != null) await api.files.delete(oldFile.id!);
    }
  }
}

class GoogleDriveConfigurationException implements Exception {
  final String message;

  const GoogleDriveConfigurationException(this.message);

  @override
  String toString() => message;
}

class _DriveSession {
  final drive.DriveApi api;
  final dynamic _client;

  const _DriveSession(this.api, this._client);

  void close() => _client.close();
}
