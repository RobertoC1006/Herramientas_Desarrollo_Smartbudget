import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction.dart';

class TransactionsNotifier extends Notifier<List<TransactionItem>> {
  @override
  List<TransactionItem> build() {
    return [];
  }

  void addTransaction(TransactionItem transaction) {
    state = [transaction, ...state];
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  double get totalExpenses {
    return state.where((t) => !t.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return state.where((t) => t.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }
}

final transactionsProvider = NotifierProvider<TransactionsNotifier, List<TransactionItem>>(TransactionsNotifier.new);
