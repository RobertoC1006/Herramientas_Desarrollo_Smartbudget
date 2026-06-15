import 'package:flutter/material.dart';
import '../../core/utils/category_utils.dart';

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;
  final IconData icon;
  final Color categoryColor;
  final Color categoryBackground;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isIncome = false,
    required this.icon,
    this.categoryColor = const Color(0xFF64748B),
    this.categoryBackground = const Color(0xFFF1F5F9),
  });

  factory TransactionItem.fromExpenseJson(Map<String, dynamic> json) {
    final String category = _mapBackendCategoryToFrontend(json['categoria'] as String);
    final info = CategoryUtils.getCategoryInfo(category);
    final String idStr = json['id'].toString();
    
    // Si hay descripción, la usamos como título. Si no, usamos el comercio. Si tampoco hay, la categoría.
    String titleStr = category;
    if (json['descripcion'] != null && (json['descripcion'] as String).trim().isNotEmpty) {
      titleStr = json['descripcion'] as String;
    } else if (json['comercio'] != null && (json['comercio'] as String).trim().isNotEmpty) {
      titleStr = json['comercio'] as String;
    }

    // El backend envía 'fecha' como "YYYY-MM-DD"
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['fecha'] as String);
    } catch (_) {
      parsedDate = json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now();
    }

    return TransactionItem(
      id: idStr,
      title: titleStr,
      amount: (json['monto'] as num).toDouble(),
      date: parsedDate,
      category: category,
      icon: info.icon,
      categoryColor: info.color,
      categoryBackground: info.background,
      isIncome: false,
    );
  }

  static String _mapBackendCategoryToFrontend(String backendCategory) {
    switch (backendCategory.toLowerCase()) {
      case 'comida':
        return 'Comida';
      case 'transporte':
        return 'Transporte';
      case 'ocio':
        return 'Ocio';
      case 'salud':
        return 'Salud';
      case 'educacion':
        return 'Educación';
      case 'otros':
      case 'ropa':
      case 'hogar':
      case 'tecnologia':
      case 'viajes':
      default:
        return 'Otros';
    }
  }

  static String mapFrontendCategoryToBackend(String frontendCategory) {
    switch (frontendCategory) {
      case 'Comida':
        return 'comida';
      case 'Transporte':
        return 'transporte';
      case 'Ocio':
        return 'ocio';
      case 'Salud':
        return 'salud';
      case 'Educación':
        return 'educacion';
      case 'Otros':
      default:
        return 'otros';
    }
  }
}
