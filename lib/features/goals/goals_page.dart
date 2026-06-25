import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final IconData icon;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.icon,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => GoalsPageState();
}

/// 👇 IMPORTANTE: clase pública (sin _)
class GoalsPageState extends State<GoalsPage> {
  final List<Goal> _goals = [];

  double get _totalAhorrado {
    return _goals.fold(0, (sum, goal) => sum + goal.currentAmount);
  }

  /// 🤖 IA GLOBAL (AHORA FUNCIONA DESDE MainLayout)
  void showIASuggestion() {
    if (_goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero crea una meta")),
      );
      return;
    }

    final goal = _goals.reduce((a, b) => a.progress < b.progress ? a : b);

    final faltante = goal.targetAmount - goal.currentAmount;
    final semanal = (faltante / 4).clamp(10, faltante);
    final diario = (faltante / 30).clamp(1, faltante);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🤖 Asistente IA"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Meta: ${goal.name}"),
            const SizedBox(height: 10),
            Text("Faltan S/ ${faltante.toStringAsFixed(2)}"),
            const SizedBox(height: 15),
            Text("💡 Semanal: S/ ${semanal.toStringAsFixed(2)}"),
            Text("📅 Diario: S/ ${diario.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddGoalDialog(),
    ).then((newGoal) {
      if (newGoal != null && newGoal is Goal) {
        setState(() {
          _goals.add(newGoal);
        });
      }
    });
  }

  void _showAddFoundsDialog(Goal goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Abonar a ${goal.name}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Monto"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;

                if (amount > 0) {
                  setState(() {
                    goal.currentAmount += amount;
                  });

                  Navigator.pop(context);

                  if (goal.progress >= 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("🎉 Meta completada: ${goal.name}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text("Abonar"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mis Metas', style: AppTextStyles.heading2),
                        const SizedBox(height: 4),
                        Text(
                          'Ahorra para tus sueños',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (_goals.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: showIASuggestion,
                            icon: const Icon(Icons.auto_awesome_outlined),
                            color: AppColors.primary,
                          ),
                        ),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _showAddGoalDialog,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x334F46E5),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahorro total',
                      style: AppTextStyles.small.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S/ ${_totalAhorrado.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _goals.isEmpty
                          ? 'Crea tu primera meta para empezar a ahorrar.'
                          : 'Tu progreso está en marcha.',
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_goals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F111827),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No hay metas aún',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Agrega una meta para empezar a organizar tus ahorros.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildGoalCard(_goals[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final progressPercent = (goal.progress * 100).round();
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F111827),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(goal.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      'Meta: S/ ${goal.targetAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progressPercent% completado',
                style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'S/ ${goal.currentAmount.toStringAsFixed(2)}',
                style: AppTextStyles.small.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.progress >= 1 ? AppColors.primary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Faltan S/ ${remaining.toStringAsFixed(2)}',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showAddFoundsDialog(goal),
                icon: const Icon(Icons.add),
                label: const Text('Abonar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.flag_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Nueva Meta'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nombre de la meta',
              prefixIcon: Icon(Icons.emoji_events_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Monto objetivo',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final amount = double.tryParse(_amountController.text) ?? 0;

            if (name.isEmpty || amount <= 0) {
              return;
            }

            final goal = Goal(
              id: DateTime.now().toString(),
              name: name,
              targetAmount: amount,
              icon: Icons.star,
            );
            Navigator.pop(context, goal);
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}