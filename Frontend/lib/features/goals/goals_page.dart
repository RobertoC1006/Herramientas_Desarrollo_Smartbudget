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
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<Goal> _goals = [];

  double get _totalAhorrado {
    return _goals.fold(0, (sum, goal) => sum + goal.currentAmount);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Abonar a ${goal.name}', style: AppTextStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monto a abonar (S/)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount > 0) {
                  Navigator.pop(context, amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Abonar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((amount) {
      if (amount != null && amount is double) {
        setState(() {
          goal.currentAmount += amount;

          // 🎉 MENSAJE AL COMPLETAR
          if (goal.progress >= 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🎉 ¡Meta '${goal.name}' completada!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mis Metas', style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      Text(
                        'Ahorra para tus sueños',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _showAddGoalDialog,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// TOTAL AHORRADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total ahorrado",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Text(
                      "S/ ${_totalAhorrado.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No hay metas aún"),
    );
  }

  Widget _buildGoalsList() {
    return ListView.separated(
      itemCount: _goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final goal = _goals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// TITULO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.name, style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _goals.remove(goal);
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// PROGRESO TEXTO
            Text(
              "S/ ${goal.currentAmount} / ${goal.targetAmount}",
            ),

            const SizedBox(height: 10),

            /// PROGRESS BAR CON ANIMACIÓN
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.progress),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                );
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _showAddFoundsDialog(goal),
              child: const Text("Abonar"),
            ),
          ],
        ),
      ),
    );
  }
}

/// DIALOGO
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
      title: const Text("Nueva Meta"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController),
          TextField(controller: _amountController),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final goal = Goal(
              id: DateTime.now().toString(),
              name: _nameController.text,
              targetAmount: double.parse(_amountController.text),
              icon: Icons.star,
            );
            Navigator.pop(context, goal);
          },
          child: const Text("Crear"),
        )
      ],
    );
  }
}