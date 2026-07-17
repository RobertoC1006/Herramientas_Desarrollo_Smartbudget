import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum StatusAlertTone { success, warning, danger, info }

class StatusAlert extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final StatusAlertTone tone;

  const StatusAlert({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = StatusAlertTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.foreground.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.foreground, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTextStyles.small.copyWith(
                      color: colors.foreground.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusAlertColors _toneColors(StatusAlertTone tone) {
    return switch (tone) {
      StatusAlertTone.success => const _StatusAlertColors(
        background: AppColors.primaryLight,
        foreground: AppColors.primaryDark,
      ),
      StatusAlertTone.warning => const _StatusAlertColors(
        background: AppColors.warningSoft,
        foreground: Color(0xFF92400E),
      ),
      StatusAlertTone.danger => const _StatusAlertColors(
        background: AppColors.dangerSoft,
        foreground: Color(0xFFB91C1C),
      ),
      StatusAlertTone.info => const _StatusAlertColors(
        background: AppColors.infoSoft,
        foreground: AppColors.info,
      ),
    };
  }
}

class _StatusAlertColors {
  final Color background;
  final Color foreground;

  const _StatusAlertColors({
    required this.background,
    required this.foreground,
  });
}

