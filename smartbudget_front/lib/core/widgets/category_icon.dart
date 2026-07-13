import 'package:flutter/material.dart';

import '../utils/category_utils.dart';

class CategoryIcon extends StatelessWidget {
  final CategoryInfo info;
  final double size;
  final double iconSize;

  const CategoryIcon({
    super.key,
    required this.info,
    this.size = 36,
    double? iconSize,
  }) : iconSize = iconSize ?? size * 0.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: info.background,
          shape: BoxShape.circle,
          border: Border.all(color: info.color.withValues(alpha: 0.16)),
        ),
        child: Center(
          child: Icon(info.icon, color: info.color, size: iconSize),
        ),
      ),
    );
  }
}

