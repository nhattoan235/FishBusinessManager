import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../../application/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _backup() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final path = await repo.createBackup();
      if (mounted) {
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sao lưu thành công!\nĐã lưu tại: $path'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi sao lưu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text('Khôi phục sẽ ghi đè toàn bộ dữ liệu hiện tại. Ứng dụng cần khởi động lại sau khi khôi phục. Bạn có chắc chắn không?'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => context.pop(true), 
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đồng ý')
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final success = await repo.restoreBackup();
      if (mounted && success) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Khôi phục thành công'),
            content: const Text('Dữ liệu đã được khôi phục. Vui lòng khởi động lại ứng dụng để áp dụng.'),
            actions: [
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khôi phục: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // ─── Giao diện ────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'Giao diện',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                settingsAsync.when(
                  data: (settings) => Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.format_size),
                          title: const Text('Cỡ chữ'),
                          subtitle: Slider(
                            value: settings.fontScale,
                            min: 1.0,
                            max: 1.5,
                            divisions: 5,
                            label: settings.fontScale.toStringAsFixed(1),
                            onChanged: (val) {
                              final db = ref.read(databaseProvider);
                              db.settingsDao.updateSettings(
                                settings.toCompanion(true).copyWith(fontScale: drift.Value(val))
                              );
                            },
                          ),
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.format_bold),
                          title: const Text('Chữ in đậm'),
                          subtitle: const Text('Hiển thị chữ đậm cho dễ đọc'),
                          value: settings.useBoldFont,
                          onChanged: (val) {
                            final db = ref.read(databaseProvider);
                            db.settingsDao.updateSettings(
                              settings.toCompanion(true).copyWith(useBoldFont: drift.Value(val))
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Lỗi: $e'),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ─── Sao lưu ──────────────────────────────────────────────────
                if (!kIsWeb) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      'Sao lưu & Khôi phục',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text('Sao lưu dữ liệu'),
                      subtitle: const Text('Lưu toàn bộ dữ liệu ra file'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _backup,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restore),
                      title: const Text('Khôi phục dữ liệu'),
                      subtitle: const Text('Tải lại dữ liệu từ file sao lưu'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _restore,
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('Tính năng sao lưu không hỗ trợ trên trình duyệt Web.',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
    );
  }
}
