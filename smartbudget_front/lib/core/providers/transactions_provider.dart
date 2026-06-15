import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/expense_repository.dart';
import 'budget_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

class TransactionsNotifier extends AsyncNotifier<List<TransactionItem>> {
  late final ExpenseRepository _repository;

  @override
  Future<List<TransactionItem>> build() async {
    _repository = ref.read(expenseRepositoryProvider);
    return _loadExpenses();
  }

  Future<List<TransactionItem>> _loadExpenses() async {
    try {
      final now = DateTime.now();
      return await _repository.fetchExpenses(mes: now.month, anio: now.year);
    } catch (_) {
      return [];
    }
  }

  Future<void> addTransaction({
    required String category,
    required double amount,
    String? description,
    String? merchant,
    required DateTime date,
    String source = 'manual',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createExpense(
        categoria: category,
        monto: amount,
        descripcion: description,
        comercio: merchant,
        fecha: date,
        fuente: source,
      );
      // Refrescar presupuesto tras cambios
      ref.read(budgetProvider.notifier).refresh();
      return _loadExpenses();
    });
  }

  Future<void> removeTransaction(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteExpense(intId);
      // Refrescar presupuesto tras cambios
      ref.read(budgetProvider.notifier).refresh();
      return _loadExpenses();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadExpenses());
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionItem>>(
  TransactionsNotifier.new,
);
