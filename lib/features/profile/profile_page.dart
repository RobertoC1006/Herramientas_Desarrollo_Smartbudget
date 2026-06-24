import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/budget_provider.dart';
import '../../core/providers/transactions_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    final initialBudget = ref.read(budgetProvider);
    _budgetController =
        TextEditingController(text: initialBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go(LoginPage.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    final budget = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionsProvider);

    final totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);

    final available = budget + totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(
                    user?.nombre ?? 'Usuario',
                    user?.email ?? 'usuario@email.com',
                  ),
                  const SizedBox(height: 20),

                  _buildFinancialSummaryCard(
                    budget,
                    totalIncome,
                    totalExpenses,
                    available,
                  ),
                  const SizedBox(height: 20),

                  _buildBudgetSection(),
                  const SizedBox(height: 20),

                  _buildSettingsSection(),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Cuenta activa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
    double budget,
    double totalIncome,
    double totalExpenses,
    double available,
  ) {
    final usedPercentage =
        budget > 0 ? (totalExpenses / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Resumen financiero',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildFinanceRow(
            'Presupuesto',
            'S/ ${budget.toStringAsFixed(2)}',
            Icons.account_balance_wallet_outlined,
            AppColors.primary,
          ),
          const SizedBox(height: 12),

          _buildFinanceRow(
            'Ingresos adicionales',
            'S/ ${totalIncome.toStringAsFixed(2)}',
            Icons.arrow_downward,
            Colors.green,
          ),
          const SizedBox(height: 12),

          _buildFinanceRow(
            'Gastos realizados',
            'S/ ${totalExpenses.toStringAsFixed(2)}',
            Icons.arrow_upward,
            AppColors.danger,
          ),
          const SizedBox(height: 12),

          _buildFinanceRow(
            'Disponible',
            'S/ ${available.toStringAsFixed(2)}',
            Icons.savings_outlined,
            available >= 0 ? AppColors.primary : AppColors.danger,
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usedPercentage,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPercentage > 0.9
                    ? AppColors.danger
                    : usedPercentage > 0.7
                        ? AppColors.warning
                        : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Has usado ${(usedPercentage * 100).toStringAsFixed(0)}% de tu presupuesto',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Presupuesto Mensual',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingresa el dinero total que tienes disponible este mes',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Monto Total (S/)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final newBudget = double.tryParse(value) ?? 0.0;
              ref.read(budgetProvider.notifier).updateBudget(newBudget);
            },
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  'Presupuesto configurado: ',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'S/ ${ref.watch(budgetProvider).toStringAsFixed(2)}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Configuración',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            label: 'Notificaciones',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            label: 'Privacidad y seguridad',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.settings_outlined,
            label: 'Configuración',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.help_outline,
            label: 'Ayuda y soporte',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}