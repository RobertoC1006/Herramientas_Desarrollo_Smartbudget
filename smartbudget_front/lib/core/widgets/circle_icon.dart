import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const CircleIcon({
    super.key,
    required this.icon,
    this.size = 41,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary, size: iconSize),
    );
  }
}
