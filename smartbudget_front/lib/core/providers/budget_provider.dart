import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetNotifier extends Notifier<double> {
  @override
  double build() {
    // Initial default budget
    return 2000.00;
  }

  void updateBudget(double newBudget) {
    state = newBudget;
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, double>(BudgetNotifier.new);
