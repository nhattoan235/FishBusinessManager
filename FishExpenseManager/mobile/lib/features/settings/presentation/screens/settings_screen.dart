import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../application/settings_provider.dart';
import '../../domain/entities/backup_entry.dart';
import '../../infrastructure/services/google_drive_backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  bool _driveConfigured = false;
  String? _googleEmail;
  List<BackupEntry> _driveBackups = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_restoreGoogleSession);
  }

  Future<void> _restoreGoogleSession() async {
    if (kIsWeb) return;
    final driveService = ref.read(googleDriveBackupServiceProvider);
    try {
      final configured = await driveService.isConfigured();
      if (mounted) setState(() => _driveConfigured = configured);
      if (!configured) return;
      final email = await driveService.restoreSession();
      if (mounted) setState(() => _googleEmail = email);
      if (email != null) {
        final settings = await ref.read(appSettingsProvider.future);
        if (!settings.useGoogleDrive) {
          await _updateSettings(
            settings,
            settings
                .toCompanion(true)
                .copyWith(useGoogleDrive: const drift.Value(true)),
          );
        }
      }
    } catch (_) {
      // A missing/expired session is represented by the disconnected UI.
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _backup(AppSettingData settings) async {
    setState(() => _isLoading = true);
    try {
      final path = await ref.read(backupRepositoryProvider).createBackup();
      if (path == null) return;
      if (_googleEmail != null) {
        final result =
            await ref.read(cloudBackupCoordinatorProvider).enqueueAndUpload(
                  path,
                  promptIfNecessary: true,
                );
        ref.invalidate(localBackupsProvider);
        if (result.isUploaded) {
          await _refreshDriveBackups();
          _message('Đã sao lưu trên máy và tải thành công lên Google Drive.');
        } else {
          await _showDriveUploadPending(result.error);
        }
        return;
      }
      ref.invalidate(localBackupsProvider);
      _message('Đã sao lưu dữ liệu trên máy.');
    } catch (error) {
      _message('Không thể sao lưu: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showDriveUploadPending(Object? error) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa tải được lên Google Drive'),
        content: SelectableText(
          'Bản sao lưu đã được lưu an toàn trên máy và vẫn nằm trong hàng chờ. '
          'Ứng dụng sẽ thử lại khi mở lần sau.\n\nChi tiết lỗi:\n$error',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmRestore() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận khôi phục'),
            content: const Text(
              'Dữ liệu hiện tại sẽ được sao lưu an toàn trước khi khôi phục. '
              'Bạn cần mở lại ứng dụng sau khi hoàn tất.',
            ),
            actions: [
              TextButton(
                  onPressed: () => context.pop(false),
                  child: const Text('Hủy')),
              FilledButton(
                onPressed: () => context.pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Khôi phục'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _restore({String? path}) async {
    if (!await _confirmRestore() || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(backupRepositoryProvider);
      final success = path == null
          ? await repository.restoreBackup()
          : await repository.restoreFromPath(path);
      if (success && mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Khôi phục thành công'),
            content: const Text(
                'Vui lòng đóng và mở lại ứng dụng để dùng dữ liệu vừa khôi phục.'),
            actions: [
              FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Đã hiểu')),
            ],
          ),
        );
      }
    } catch (error) {
      _message('Không thể khôi phục: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _connectDrive(AppSettingData settings) async {
    final driveService = ref.read(googleDriveBackupServiceProvider);
    if (!await driveService.isConfigured()) {
      await _configureDrive(settings);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final email = await driveService.connect();
      await _updateSettings(
        settings,
        settings
            .toCompanion(true)
            .copyWith(useGoogleDrive: const drift.Value(true)),
      );
      if (mounted) setState(() => _googleEmail = email);
      await _refreshDriveBackups();
      _message('Đã kết nối Google Drive.');
    } on GoogleDriveConfigurationException catch (error) {
      await _showDriveConfigurationHelp(error.message);
    } catch (error, stackTrace) {
      debugPrint('Google Drive connection failed: $error\n$stackTrace');
      await _showDriveConfigurationHelp(
        'Google trả về lỗi:\n\n$error\n\n'
        'Package: com.fishbusinessmanager.app\n'
        'SHA-1: 42:8A:08:E9:00:20:A4:6A:C5:65:5B:A2:30:A5:66:28:61:53:FA:9E',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _configureDrive(AppSettingData settings) async {
    final controller = TextEditingController();
    final clientId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập Web Client ID'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dán Client ID của OAuth client loại Web application. Giá trị '
                'phải kết thúc bằng .apps.googleusercontent.com.',
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Web Client ID',
                  hintText: '123...apps.googleusercontent.com',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Không nhập Client secret hoặc mật khẩu Google.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                FocusScope.of(context).unfocus();
                context.pop(value);
              }
            },
            child: const Text('Lưu và kết nối'),
          ),
        ],
      ),
    );
    // showDialog completes while the route is still finishing its reverse
    // transition. Let inherited widgets and the text field detach before
    // disposing the controller or opening Android Credential Manager.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    controller.dispose();
    if (clientId == null || !mounted) return;

    try {
      final driveService = ref.read(googleDriveBackupServiceProvider);
      final canConnectImmediately =
          await driveService.saveServerClientId(clientId);
      if (mounted) setState(() => _driveConfigured = true);
      if (!canConnectImmediately) {
        _message(
          'Đã lưu Client ID. Hãy đóng hoàn toàn rồi mở lại ứng dụng để kết nối.',
        );
        return;
      }
      _message('Đã lưu Web Client ID. Đang mở đăng nhập Google...');
      await _connectDrive(settings);
    } on FormatException catch (error) {
      _message(error.message);
    } catch (error) {
      _message('Không thể lưu Client ID: $error');
    }
  }

  Future<void> _showDriveConfigurationHelp(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa cấu hình Google Drive'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupHelp() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu hoạt động thế nào?'),
        content: const SingleChildScrollView(
          child: Text(
            '• Sao lưu ngay: tạo một file ZIP trên máy, gồm dữ liệu, metadata '
            'và checksum SHA-256 để phát hiện file hỏng.\n\n'
            '• Sao lưu tự động: chỉ chạy khi có thay đổi dữ liệu; được kích hoạt '
            'khi rời ứng dụng, đủ số giao dịch hoặc đến lịch đã chọn.\n\n'
            '• Google Drive: nếu đã kết nối, bản ZIP được đưa vào hàng chờ tải '
            'lên. Mất mạng không làm mất bản trên máy; ứng dụng sẽ thử lại khi '
            'có mạng.\n\n'
            '• Lưu trữ: giữ tối đa 10 bản trên máy và 30 bản trên Drive.\n\n'
            '• Khôi phục: ứng dụng kiểm tra checksum, tự sao lưu dữ liệu hiện '
            'tại rồi mới thay database. Sau đó cần mở lại ứng dụng.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnectDrive(AppSettingData settings) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(googleDriveBackupServiceProvider).disconnect();
      await _updateSettings(
        settings,
        settings
            .toCompanion(true)
            .copyWith(useGoogleDrive: const drift.Value(false)),
      );
      if (mounted) {
        setState(() {
          _googleEmail = null;
          _driveBackups = const [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshDriveBackups() async {
    try {
      final entries = await ref
          .read(googleDriveBackupServiceProvider)
          .listBackups(promptIfNecessary: true);
      if (mounted) setState(() => _driveBackups = entries);
    } catch (error) {
      _message('Không thể tải danh sách Google Drive: $error');
    }
  }

  Future<void> _restoreDrive(BackupEntry entry) async {
    setState(() => _isLoading = true);
    try {
      final path =
          await ref.read(googleDriveBackupServiceProvider).download(entry);
      if (mounted) setState(() => _isLoading = false);
      await _restore(path: path);
    } catch (error) {
      _message('Không thể tải bản sao lưu: $error');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSettings(
    AppSettingData current,
    AppSettingsCompanion companion,
  ) async {
    await ref.read(databaseProvider).settingsDao.updateSettings(companion);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Stack(
        children: [
          settingsAsync.when(
            data: _content,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Không thể tải cài đặt: $error')),
          ),
          if (_isLoading)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _content(AppSettingData settings) {
    final driveConfigured = _driveConfigured;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _SectionTitle('Giao diện'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('Cỡ chữ'),
                subtitle: Slider(
                  value: settings.fontScale,
                  min: 1,
                  max: 1.5,
                  divisions: 5,
                  label: settings.fontScale.toStringAsFixed(1),
                  onChanged: (value) => _updateSettings(
                    settings,
                    settings
                        .toCompanion(true)
                        .copyWith(fontScale: drift.Value(value)),
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.format_bold),
                title: const Text('Chữ in đậm'),
                value: settings.useBoldFont,
                onChanged: (value) => _updateSettings(
                  settings,
                  settings
                      .toCompanion(true)
                      .copyWith(useBoldFont: drift.Value(value)),
                ),
              ),
            ],
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Sao lưu tự động'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.schedule),
                  title: const Text('Tự động sao lưu'),
                  subtitle: const Text(
                      'Khi rời ứng dụng, theo lịch và sau N giao dịch'),
                  value: settings.autoBackup,
                  onChanged: (value) => _updateSettings(
                    settings,
                    settings
                        .toCompanion(true)
                        .copyWith(autoBackup: drift.Value(value)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Khoảng thời gian'),
                  trailing: DropdownButton<int>(
                    value: settings.backupInterval,
                    items: const [6, 12, 24, 48]
                        .map((hours) => DropdownMenuItem(
                              value: hours,
                              child: Text('$hours giờ'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSettings(
                          settings,
                          settings.toCompanion(true).copyWith(
                                backupInterval: drift.Value(value),
                              ),
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Sao lưu sau số giao dịch'),
                  trailing: DropdownButton<int>(
                    value: settings.backupTransactionThreshold,
                    items: const [5, 10, 20, 50]
                        .map((count) => DropdownMenuItem(
                              value: count,
                              child: Text('$count'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSettings(
                          settings,
                          settings.toCompanion(true).copyWith(
                                backupTransactionThreshold: drift.Value(value),
                              ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Google Drive'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text(
                    driveConfigured
                        ? (_googleEmail ?? 'Chưa kết nối')
                        : 'Chưa cấu hình OAuth',
                  ),
                  subtitle: Text(
                    driveConfigured
                        ? 'Tối đa 30 bản sao lưu gần nhất'
                        : 'Cần cấu hình một lần trước khi kết nối',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _googleEmail == null
                        ? Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            alignment: WrapAlignment.end,
                            children: [
                              if (driveConfigured)
                                OutlinedButton.icon(
                                  onPressed: () => _configureDrive(settings),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Đổi Client ID'),
                                ),
                              FilledButton.icon(
                                onPressed: () => driveConfigured
                                    ? _connectDrive(settings)
                                    : _configureDrive(settings),
                                icon: Icon(
                                  driveConfigured
                                      ? Icons.login
                                      : Icons.info_outline,
                                ),
                                label: Text(
                                  driveConfigured
                                      ? 'Kết nối'
                                      : 'Nhập Client ID',
                                ),
                              ),
                            ],
                          )
                        : TextButton(
                            onPressed: () => _disconnectDrive(settings),
                            child: const Text('Ngắt kết nối'),
                          ),
                  ),
                ),
                if (_googleEmail != null)
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Tải danh sách bản sao lưu Drive'),
                    onTap: _refreshDriveBackups,
                  ),
                ..._driveBackups.take(5).map(
                      (entry) => _BackupTile(
                        entry: entry,
                        onRestore: () => _restoreDrive(entry),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Sao lưu & Khôi phục'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Sao lưu hoạt động thế nào?'),
                  subtitle: const Text(
                    'Phân biệt bản trên máy, Google Drive và cách khôi phục',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showBackupHelp,
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Sao lưu ngay'),
                  subtitle:
                      const Text('Tạo ZIP có metadata và checksum SHA-256'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _backup(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Chọn file để khôi phục'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _restore(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ref.watch(localBackupsProvider).when(
                data: (entries) => Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.phone_android),
                        title: Text('Bản sao lưu trên máy'),
                        subtitle: Text('Giữ tối đa 10 bản gần nhất'),
                      ),
                      if (entries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text('Chưa có bản sao lưu.'),
                        ),
                      ...entries.take(5).map(
                            (entry) => _BackupTile(
                              entry: entry,
                              onRestore: () => _restore(path: entry.path),
                            ),
                          ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Không thể đọc bản sao lưu: $error'),
              ),
        ] else
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
                'Sao lưu file và mã hóa SQLCipher chỉ chạy trên ứng dụng thiết bị.'),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
}

class _BackupTile extends StatelessWidget {
  final BackupEntry entry;
  final VoidCallback onRestore;

  const _BackupTile({required this.entry, required this.onRestore});

  @override
  Widget build(BuildContext context) => ListTile(
        leading:
            Icon(entry.storage == 'drive' ? Icons.cloud_done : Icons.archive),
        title:
            Text(entry.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${(entry.fileSize / 1024).toStringAsFixed(1)} KB'),
        trailing:
            TextButton(onPressed: onRestore, child: const Text('Khôi phục')),
      );
}
