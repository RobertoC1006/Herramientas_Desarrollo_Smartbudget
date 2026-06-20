import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/smart_alert.dart';
import '../../data/repositories/alerts_repository.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository();
});

class AlertsNotifier extends AsyncNotifier<List<SmartAlert>> {
  late final AlertsRepository _repository;

  @override
  Future<List<SmartAlert>> build() async {
    _repository = ref.read(alertsRepositoryProvider);
    try {
      await _repository.triggerGenerateAlerts();
    } catch (_) {
      // Ignorar fallos de generación y cargar las alertas existentes
    }
    return _loadAlerts();
  }

  Future<List<SmartAlert>> _loadAlerts() async {
    return _repository.fetchAlerts();
  }

  Future<void> generateAndFetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.triggerGenerateAlerts();
      return _loadAlerts();
    });
  }

  Future<void> markAlertAsRead(int alertId) async {
    // Actualización optimista local
    final currentList = state.value ?? [];
    final updatedList = currentList.map((a) {
      if (a.id == alertId) {
        return SmartAlert(
          id: a.id,
          userId: a.userId,
          tipo: a.tipo,
          titulo: a.titulo,
          mensaje: a.mensaje,
          leida: true,
          createdAt: a.createdAt,
        );
      }
      return a;
    }).toList();
    
    state = AsyncValue.data(updatedList);

    try {
      await _repository.markAsRead(alertId);
    } catch (e) {
      // Revertir si falla la petición
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAlerts());
  }
}

final alertsProvider = AsyncNotifierProvider<AlertsNotifier, List<SmartAlert>>(
  AlertsNotifier.new,
);
