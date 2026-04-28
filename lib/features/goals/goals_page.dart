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
  const GoalsPage({Key? key}) : super(key: key);

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
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      Text('Ahorra para tus sueños', style: AppTextStyles.body),
                    ],
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _showAddGoalDialog,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// TOTAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "S/ ${_totalAhorrado.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _goals.isEmpty
                    ? const Center(child: Text("No hay metas aún"))
                    : ListView.builder(
                        itemCount: _goals.length,
                        itemBuilder: (_, i) => _buildGoalCard(_goals[i]),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(goal.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: goal.progress),
            const SizedBox(height: 10),
            Text("S/ ${goal.currentAmount} / ${goal.targetAmount}"),
            ElevatedButton(
              onPressed: () => _showAddFoundsDialog(goal),
              child: const Text("Abonar"),
            )
          ],
        ),
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
              targetAmount:
                  double.tryParse(_amountController.text) ?? 0,
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