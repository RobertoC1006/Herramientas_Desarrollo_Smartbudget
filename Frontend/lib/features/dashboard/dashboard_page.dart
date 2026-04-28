import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/budget_provider.dart';
import '../../core/providers/transactions_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction.dart';
import '../expenses/add_expense_page.dart' show TransactionTile;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionsProvider);

    final totalExpenses = transactions.where((t) => !t.isIncome).fold(0.0, (sum, item) => sum + item.amount);
    final totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (sum, item) => sum + item.amount);

    final balance = budget - totalExpenses + totalIncome;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildBalanceCard(balance),
                  const SizedBox(height: 24),
                  _buildIncomeExpenseRow(budget + totalIncome, totalExpenses),
                  const SizedBox(height: 30),
                  const Text('Presupuesto Mensual', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildBudgetProgress(budget, totalExpenses),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transacciones Recientes', style: AppTextStyles.heading3),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecentTransactions(transactions),
                  const SizedBox(height: 100), // Espacio extra para el FAB en web/desktop
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, Usuario!',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido de vuelta',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance Disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(double totalIncome, double totalExpenses) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Presupuesto/Ingresos',
            amount: 'S/ ${totalIncome.toStringAsFixed(2)}',
            icon: Icons.arrow_downward,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Gastos',
            amount: 'S/ ${totalExpenses.toStringAsFixed(2)}',
            icon: Icons.arrow_upward,
            iconColor: AppColors.danger,
            backgroundColor: AppColors.danger.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(double budget, double totalExpenses) {
    final progress = budget > 0 ? (totalExpenses / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget - totalExpenses).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gastado', style: AppTextStyles.label),
              Text(
                'S/ ${totalExpenses.toStringAsFixed(2)} / S/ ${budget.toStringAsFixed(2)}',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9 ? AppColors.danger : (progress > 0.7 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Te quedan S/ ${remaining.toStringAsFixed(2)} para este mes',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<TransactionItem> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text('No hay transacciones aún',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ]),
      );
    }

    final recent = transactions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: recent.map((tx) => TransactionTile(transaction: tx)).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.small),
          const SizedBox(height: 4),
          Text(amount, style: AppTextStyles.label.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
