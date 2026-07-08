import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/providers/transactions_provider.dart';
import '../../core/providers/smartscore_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction.dart';
import '../../data/models/smart_core_snapshot.dart';
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
    final transactionsState = ref.watch(transactionsProvider);
    final historyState = ref.watch(smartScoreHistoryProvider);

    return transactionsState.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error al cargar datos del análisis: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (transactions) {
        final expenses = transactions.where((t) => !t.isIncome).toList();

        // Calculate expenses by category
        final Map<String, double> expensesByCategory = {};
        for (var expense in expenses) {
          expensesByCategory[expense.category] =
              (expensesByCategory[expense.category] ?? 0.0) + expense.amount;
        }

        final categories = expensesByCategory.keys.toList();

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

                  _buildDistributionCard(expensesByCategory, categories),
                  const SizedBox(height: 24),

                  _buildWhatIfCard(expensesByCategory, categories),
                  const SizedBox(height: 24),

                  _buildScoreHistoryCard(context, ref, historyState),
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
      },
    );
  }

  Widget _buildScoreHistoryCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SmartScoreSnapshot>> historyState,
  ) {
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
                  Icons.show_chart,
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
                      'Historial de Salud Financiera',
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Evolución mensual de tu SmartScore',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          historyState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No se pudo cargar el historial de SmartScore',
                  style: AppTextStyles.small.copyWith(color: AppColors.danger),
                ),
              ),
            ),
            data: (snapshots) {
              if (snapshots.isEmpty) {
                return Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    'No hay suficiente historial para calcular tu evolución',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              // Ordenar cronológicamente para el gráfico (del más antiguo al más nuevo)
              // El backend ya los retorna ordenados, pero nos aseguramos
              final sortedSnaps = List<SmartScoreSnapshot>.from(snapshots)
                ..sort((a, b) {
                  if (a.anio != b.anio) return a.anio.compareTo(b.anio);
                  return a.mes.compareTo(b.mes);
                });

              final spots = sortedSnaps.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.score.toDouble());
              }).toList();

              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 10),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: AppColors.divider,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= sortedSnaps.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final snap = sortedSnaps[index];
                                  final monthNames = [
                                    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
                                  ];
                                  final mesStr = (snap.mes >= 1 && snap.mes <= 12)
                                      ? monthNames[snap.mes - 1]
                                      : snap.mes.toString();
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(
                                      mesStr,
                                      style: AppTextStyles.xSmall.copyWith(fontSize: 10),
                                    ),
                                  );
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 20 != 0) return const SizedBox.shrink();
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      '${value.toInt()}',
                                      style: AppTextStyles.xSmall.copyWith(fontSize: 10),
                                    ),
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          minX: 0,
                          maxX: (sortedSnaps.length - 1).toDouble(),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(
                                show: true,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

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
        children: expenses.map((tx) => TransactionTile(transaction: tx)).toList(),
      ),
    );
  }
}
