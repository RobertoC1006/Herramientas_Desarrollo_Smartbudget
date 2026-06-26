import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

class BudgetNotifier extends AsyncNotifier<BudgetSummary?> {
  late final BudgetRepository _repository;

  @override
  Future<BudgetSummary?> build() async {
    _repository = ref.read(budgetRepositoryProvider);
    return _loadBudget();
  }

  Future<BudgetSummary?> _loadBudget() async {
    try {
      return await _repository.fetchCurrentBudget();
    } catch (e) {
      final errStr = e.toString();
      // Si el backend responde 404 (no encontrado), significa que no hay presupuesto para este mes
      if (errStr.contains('404') || errStr.toLowerCase().contains('no se encontró')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> createBudget(double montoBase) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      await _repository.createBudget(
        montoBase: montoBase,
        mes: now.month,
        anio: now.year,
      );
      return _loadBudget();
    });
  }

  Future<void> addAdditionalIncome(double monto, String descripcion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addIncome(
        monto: monto,
        descripcion: descripcion,
      );
      return _loadBudget();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadBudget());
  }
}

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, BudgetSummary?>(BudgetNotifier.new);
