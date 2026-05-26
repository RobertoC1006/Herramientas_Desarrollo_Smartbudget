import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/providers/transactions_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction.dart';
import '../expenses/add_expense_page.dart' show TransactionTile;

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  String? _selectedCategoryToReduce;
  double _reductionPercentage = 25.0;

  final List<Color> _chartColors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.info,
    AppColors.danger,
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final expenses = transactions.where((t) => !t.isIncome).toList();

    // Calculate expenses by category
    final Map<String, double> expensesByCategory = {};
    for (var expense in expenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0.0) + expense.amount;
    }

    final categories = expensesByCategory.keys.toList();
    final totalExpenses = expenses.fold(
  0.0,
  (sum, item) => sum + item.amount,
);

final highestExpense = expenses.isNotEmpty
    ? expenses.reduce(
        (a, b) => a.amount > b.amount ? a : b,
      )
    : null;

String financialMessage = totalExpenses > 3000
    ? 'Tus gastos son elevados este mes'
    : totalExpenses > 1500
        ? 'Tus gastos están bajo control'
        : 'Excelente manejo financiero';

    // Auto-select first category if none selected or if selected doesn't exist anymore
    if (categories.isNotEmpty &&
        (_selectedCategoryToReduce == null ||
            !categories.contains(_selectedCategoryToReduce))) {
      _selectedCategoryToReduce = categories.first;
    } else if (categories.isEmpty) {
      _selectedCategoryToReduce = null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Análisis', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                'Visualiza y optimiza tus finanzas',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
             const SizedBox(height: 30),

_buildSummaryCard(
  totalExpenses,
  highestExpense?.category ?? 'Sin datos',
  financialMessage,
),

const SizedBox(height: 20),

_buildQuickStats(
  totalExpenses,
  expenses.length,
  highestExpense?.category ?? 'Sin datos',
),

const SizedBox(height: 24),

_buildDistributionCard(expensesByCategory, categories),
              const SizedBox(height: 24),

              _buildWhatIfCard(expensesByCategory, categories),
              const SizedBox(height: 30),
              _buildSmartInsights(expensesByCategory),
const SizedBox(height: 30),

              Text('Historial de Gastos', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              _buildHistoryList(expenses),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSummaryCard(
  double totalExpenses,
  String highestCategory,
  String message,
) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF4F46E5),
          Color(0xFF7C3AED),
        ],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 15,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Resumen Financiero',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          'Gasto Total',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'S/ ${totalExpenses.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Categoría con mayor gasto: $highestCategory',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: Colors.amber,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
  Widget _buildDistributionCard(
    Map<String, double> expensesByCategory,
    List<String> categories,
  ) {
    final totalExpense = expensesByCategory.values.fold(
      0.0,
      (sum, val) => sum + val,
    );

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribución por Categoría',
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Visualiza tus gastos por categoría',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (categories.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'Agrega gastos para ver tu distribución',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final value = expensesByCategory[category]!;
                    final percentage = totalExpense > 0
                        ? (value / totalExpense) * 100
                        : 0.0;
                    final color = _chartColors[index % _chartColors.length];

                    return PieChartSectionData(
                      color: color,
                      value: percentage,
                      title: '${percentage.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final color = _chartColors[index % _chartColors.length];
                return _buildLegendItem(color, category);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.small),
      ],
    );
  }

  Widget _buildWhatIfCard(
    Map<String, double> expensesByCategory,
    List<String> categories,
  ) {
    double currentCategoryExpense = _selectedCategoryToReduce != null
        ? (expensesByCategory[_selectedCategoryToReduce!] ?? 0.0)
        : 0.0;
    double savings = currentCategoryExpense * (_reductionPercentage / 100);

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo "¿Y si...?"',
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Simula escenarios para mejorar tu salud financiera',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Categoría a reducir', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryToReduce,
            hint: const Text('Sin gastos aún', style: AppTextStyles.body),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
            ),
            items: categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat, style: AppTextStyles.body),
              );
            }).toList(),
            onChanged: categories.isEmpty
                ? null
                : (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategoryToReduce = val;
                      });
                    }
                  },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reducción (%)', style: AppTextStyles.label),
              Text(
                '${_reductionPercentage.toInt()}%',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: _reductionPercentage,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() {
                _reductionPercentage = val;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ahorro potencial',
                        style: AppTextStyles.small,
                      ),
                      Text(
                        '+ S/ ${savings.toStringAsFixed(2)} al mes',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<TransactionItem> expenses) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Aún no has registrado ningún gasto',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: expenses
            .map((tx) => TransactionTile(transaction: tx))
            .toList(),
      ),
    );
  }

  Widget _buildSmartInsights(
    Map<String, double> expensesByCategory,
  ) {
    String message = 'Tus finanzas van bien.';
    IconData icon = Icons.check_circle;
    Color color = Colors.green;

    if (expensesByCategory.isNotEmpty) {
      final highestCategory = expensesByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      if (highestCategory.value > 500) {
        message =
            'Estás gastando mucho en ${highestCategory.key}. Considera reducir ese gasto.';
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
      }

      if (highestCategory.value > 1000) {
        message =
            'Tus gastos en ${highestCategory.key} son demasiado altos.';
        icon = Icons.error_outline;
        color = Colors.red;
      }
    }

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo Inteligente',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
  double totalExpenses,
  int totalTransactions,
  String topCategory,
) {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          Icons.account_balance_wallet,
          'Total',
          'S/ ${totalExpenses.toStringAsFixed(0)}',
          Colors.blue,
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _buildStatCard(
          Icons.receipt_long,
          'Mov.',
          '$totalTransactions',
          Colors.orange,
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _buildStatCard(
          Icons.star,
          'Top',
          topCategory,
          Colors.purple,
        ),
      ),
    ],
  );
}

Widget _buildStatCard(
  IconData icon,
  String title,
  String value,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          title,
          style: AppTextStyles.small,
        ),

        const SizedBox(height: 6),

        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}

