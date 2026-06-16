import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/goals_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/goal.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  IconData _getGoalIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('viaje') || n.contains('vuelo') || n.contains('playa') || n.contains('vacaciones')) {
      return Icons.flight;
    } else if (n.contains('casa') || n.contains('hogar') || n.contains('depa') || n.contains('alquiler') || n.contains('constru')) {
      return Icons.home;
    } else if (n.contains('auto') || n.contains('carro') || n.contains('moto') || n.contains('vehiculo')) {
      return Icons.directions_car;
    } else if (n.contains('estudio') || n.contains('universidad') || n.contains('colegio') || n.contains('curso') || n.contains('educa')) {
      return Icons.school;
    } else if (n.contains('salud') || n.contains('medico') || n.contains('clinica') || n.contains('operacion')) {
      return Icons.favorite_border;
    }
    return Icons.star_border;
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddGoalDialog(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final name = result['nombre'] as String;
        final targetAmount = result['monto_objetivo'] as double;
        
        ref.read(goalsProvider.notifier).addGoal(name, targetAmount).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al crear meta: $e')),
            );
          }
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
          title: Text('Abonar a ${goal.nombre}', style: AppTextStyles.heading3),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Abonar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((amount) {
      if (amount != null && amount is double) {
        ref.read(goalsProvider.notifier).addContribution(goal.id, amount).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al abonar: $e')),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mis Metas', style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      Text('Ahorra para tus sueños', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  FloatingActionButton(
                    heroTag: 'add_goal',
                    mini: true,
                    onPressed: _showAddGoalDialog,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: goalsState.when(
                  data: (goals) => goals.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
                          child: ListView.separated(
                            itemCount: goals.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return _buildGoalCard(goal);
                            },
                          ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 48),
                        const SizedBox(height: 16),
                        Text('Error al cargar metas', style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        Text(err.toString(), style: AppTextStyles.body, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.read(goalsProvider.notifier).refresh(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('Sin metas aún', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera meta de ahorro y comienza a\nplanificar tu futuro',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final icon = _getGoalIcon(goal.nombre);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          goal.nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progreso', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          'S/ ${goal.saldoAcumulado.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Objetivo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          'S/ ${goal.montoObjetivo.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goal.progreso,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(goal.progreso * 100).toInt()}% completado', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      'Faltan S/ ${(goal.montoObjetivo - goal.saldoAcumulado).clamp(0, double.infinity).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: goal.estaCompletada ? null : () => _showAddFoundsDialog(goal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  goal.estaCompletada ? 'Meta alcanzada' : 'Abonar a esta meta',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  final List<Map<String, dynamic>> _icons = [
    {'label': 'Viaje', 'icon': Icons.flight},
    {'label': 'Casa', 'icon': Icons.home},
    {'label': 'Auto', 'icon': Icons.directions_car},
    {'label': 'Educación', 'icon': Icons.school},
    {'label': 'Salud', 'icon': Icons.favorite_border},
    {'label': 'Otro', 'icon': Icons.star_border},
  ];
  
  int _selectedIconIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nueva Meta', style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        Text('Crea una meta de ahorro para alcanzar tus objetivos', style: AppTextStyles.xSmall),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text('Nombre de la meta', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Viaje a Europa',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                
                const Text('Monto objetivo (S/)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '5000.00',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (double.tryParse(value) == null) return 'Inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Text('Ícono (Visual)', style: AppTextStyles.label),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final item = _icons[index];
                    final isSelected = _selectedIconIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context, {
                          'nombre': _nameController.text,
                          'monto_objetivo': double.parse(_amountController.text),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Crear Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
