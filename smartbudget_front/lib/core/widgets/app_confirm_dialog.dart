import 'package:flutter/material.dart';

import '../theme/adaptive_colors.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  IconData icon = Icons.help_outline_rounded,
  Color accentColor = AppColors.primary,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: context.financeSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accentColor.withValues(alpha: 0.18)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.heading3.copyWith(
                          color: context.financeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: context.financeTextSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: context.financeTextSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          cancelLabel,
                          style: AppTextStyles.label.copyWith(
                            color: context.financeTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}

