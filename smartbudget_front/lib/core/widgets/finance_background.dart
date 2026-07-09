import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FinanceBackground extends StatelessWidget {
  final Widget child;

  const FinanceBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundSoft = isDark
        ? const Color(0xFF0B1F17)
        : AppColors.backgroundSoft;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.scaffoldBackgroundColor, backgroundSoft],
        ),
      ),
      child: CustomPaint(
        painter: _FinanceGridPainter(isDark: isDark),
        child: child,
      ),
    );
  }
}

class _FinanceGridPainter extends CustomPainter {
  final bool isDark;

  const _FinanceGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primaryDark).withValues(
        alpha: 0.035,
      )
      ..strokeWidth = 1;
    const step = 28.0;

    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

