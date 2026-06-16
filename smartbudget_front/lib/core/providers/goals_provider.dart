import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import 'budget_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  late final GoalRepository _repository;

  @override
  Future<List<Goal>> build() async {
    _repository = ref.read(goalRepositoryProvider);
    return _loadGoals();
  }

  Future<List<Goal>> _loadGoals() async {
    return _repository.fetchGoals();
  }

  Future<void> addGoal(String name, double targetAmount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createGoal(name, targetAmount);
      return _loadGoals();
    });
  }

  Future<void> addContribution(int goalId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.contributeToGoal(goalId, amount);
      // Refrescar el presupuesto ya que se resta del saldo disponible del mes actual
      ref.read(budgetProvider.notifier).refresh();
      return _loadGoals();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadGoals());
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);
