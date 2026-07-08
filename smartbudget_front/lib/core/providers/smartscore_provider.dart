import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/smart_core_snapshot.dart';
import '../../data/repositories/smartscore_repository.dart';

final smartScoreRepositoryProvider = Provider<SmartScoreRepository>((ref) {
  return SmartScoreRepository();
});

class SmartScoreNotifier extends AsyncNotifier<int> {
  late final SmartScoreRepository _repository;

  @override
  Future<int> build() async {
    _repository = ref.read(smartScoreRepositoryProvider);
    return _loadScore();
  }

  Future<int> _loadScore() async {
    try {
      return await _repository.fetchCurrentScore();
    } catch (e) {
      final errStr = e.toString();
      // Si no hay presupuesto o datos, puede fallar con 404, retornamos un score default de 0
      if (errStr.contains('404') || errStr.toLowerCase().contains('no se encontró')) {
        return 0;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadScore());
  }
}

class SmartScoreHistoryNotifier extends AsyncNotifier<List<SmartScoreSnapshot>> {
  late final SmartScoreRepository _repository;

  @override
  Future<List<SmartScoreSnapshot>> build() async {
    _repository = ref.read(smartScoreRepositoryProvider);
    return _loadHistory();
  }

  Future<List<SmartScoreSnapshot>> _loadHistory() async {
    try {
      return await _repository.fetchHistory(meses: 6);
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('404') || errStr.toLowerCase().contains('no se encontró')) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadHistory());
  }
}

final smartScoreProvider = AsyncNotifierProvider<SmartScoreNotifier, int>(
  SmartScoreNotifier.new,
);

final smartScoreHistoryProvider = AsyncNotifierProvider<SmartScoreHistoryNotifier, List<SmartScoreSnapshot>>(
  SmartScoreHistoryNotifier.new,
);
