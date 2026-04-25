import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildIncomeExpenseRow(),
                  const SizedBox(height: 30),
                  const Text('Presupuesto Mensual', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildBudgetProgress(),
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
                  _buildRecentTransactions(),
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

  Widget _buildBalanceCard() {
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
            'Balance Total',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$12,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '+8.5% este mes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Ingresos',
            amount: '\$4,200.00',
            icon: Icons.arrow_downward,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Gastos',
            amount: '\$1,850.00',
            icon: Icons.arrow_upward,
            iconColor: AppColors.danger,
            backgroundColor: AppColors.danger.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress() {
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
                '\$1,850 / \$3,000',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1850 / 3000,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Te quedan \$1,150 para este mes',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {'title': 'Supermercado', 'date': 'Hoy', 'amount': '-\$85.00', 'icon': Icons.shopping_cart_outlined},
      {'title': 'Salario', 'date': 'Ayer', 'amount': '+\$2,100.00', 'icon': Icons.work_outline, 'isIncome': true},
      {'title': 'Netflix', 'date': '15 Abr', 'amount': '-\$15.99', 'icon': Icons.movie_outlined},
      {'title': 'Restaurante', 'date': '14 Abr', 'amount': '-\$45.50', 'icon': Icons.restaurant_outlined},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx['isIncome'] == true;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome ? AppColors.primaryLight : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tx['icon'] as IconData,
                color: isIncome ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            title: Text(
              tx['title'] as String,
              style: AppTextStyles.label.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              tx['date'] as String,
              style: AppTextStyles.small,
            ),
            trailing: Text(
              tx['amount'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
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
