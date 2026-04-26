import 'package:flutter/material.dart';

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
}
