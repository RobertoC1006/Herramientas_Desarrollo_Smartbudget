import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final Color background;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class CategoryUtils {
  static const List<CategoryInfo> categories = [
    CategoryInfo(
      name: 'Comida',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B35),
      background: Color(0xFFFFF0EA),
    ),
    CategoryInfo(
      name: 'Transporte',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF3B82F6),
      background: Color(0xFFEFF6FF),
    ),
    CategoryInfo(
      name: 'Servicios',
      icon: Icons.bolt,
      color: Color(0xFFFFB020),
      background: Color(0xFFFFF8E7),
    ),
    CategoryInfo(
      name: 'Ocio',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF8B5CF6),
      background: Color(0xFFF5F3FF),
    ),
    CategoryInfo(
      name: 'Salud',
      icon: Icons.favorite_rounded,
      color: Color(0xFFE5484D),
      background: Color(0xFFFFF0F0),
    ),
    CategoryInfo(
      name: 'Educación',
      icon: Icons.school_rounded,
      color: Color(0xFF6366F1),
      background: Color(0xFFF0F0FF),
    ),
    CategoryInfo(
      name: 'Compras',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899),
      background: Color(0xFFFFF0F7),
    ),
    CategoryInfo(
      name: 'Otros',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B),
      background: Color(0xFFF1F5F9),
    ),
  ];

  static CategoryInfo getCategoryInfo(String name) {
    return categories.firstWhere(
      (c) => c.name == name,
      orElse: () => categories.last,
    );
  }
}
