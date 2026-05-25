import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool bordered;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: bordered
            ? Border.all(color: AppColors.border, width: 1.2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
