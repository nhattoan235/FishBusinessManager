import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
