import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartbudget/core/providers/alerts_provider.dart';
import 'package:smartbudget/data/models/smart_alert.dart';
import 'package:smartbudget/data/models/enums.dart';
import 'package:smartbudget/data/repositories/alerts_repository.dart';

class FakeAlertsRepository extends AlertsRepository {
  final List<SmartAlert> mockAlerts;

  FakeAlertsRepository({required this.mockAlerts});

  @override
  Future<List<SmartAlert>> fetchAlerts() async {
    return mockAlerts;
  }

  @override
  Future<void> triggerGenerateAlerts() async {
    // Simular generación exitosa sin hacer peticiones HTTP
  }

  @override
  Future<SmartAlert> markAsRead(int alertId) async {
    final alert = mockAlerts.firstWhere((a) => a.id == alertId);
    return SmartAlert(
      id: alert.id,
      userId: alert.userId,
      tipo: alert.tipo,
      titulo: alert.titulo,
      mensaje: alert.mensaje,
      leida: true,
      createdAt: alert.createdAt,
    );
  }
}

void main() {
  group('AlertsNotifier Tests', () {
    test('Cargar alertas iniciales correctamente tras generar nuevas', () async {
      final mockAlerts = [
        SmartAlert(
          id: 1,
          userId: 1,
          tipo: TipoAlerta.critica,
          titulo: 'Alerta Crítica Test',
          mensaje: 'Gasto excesivo detectado en comida',
          leida: false,
          createdAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          alertsRepositoryProvider.overrideWithValue(
            FakeAlertsRepository(mockAlerts: mockAlerts),
          ),
        ],
      );

      addTearDown(container.dispose);

      // Esperamos que resuelva las alertas asíncronas
      final alerts = await container.read(alertsProvider.future);
      
      expect(alerts.length, 1);
      expect(alerts.first.titulo, 'Alerta Crítica Test');
      expect(alerts.first.leida, false);
      expect(alerts.first.tipo, TipoAlerta.critica);
    });

    test('Marcar alerta como leída actualiza el estado local', () async {
      final mockAlerts = [
        SmartAlert(
          id: 42,
          userId: 1,
          tipo: TipoAlerta.advertencia,
          titulo: 'Sobregiro inminente',
          mensaje: 'Has gastado el 85% de tu presupuesto',
          leida: false,
          createdAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          alertsRepositoryProvider.overrideWithValue(
            FakeAlertsRepository(mockAlerts: mockAlerts),
          ),
        ],
      );

      addTearDown(container.dispose);

      // Cargar estado inicial
      await container.read(alertsProvider.future);

      // Ejecutar acción
      await container.read(alertsProvider.notifier).markAlertAsRead(42);

      // Verificar que el estado cambió
      final list = container.read(alertsProvider).value;
      expect(list, isNotNull);
      expect(list!.length, 1);
      expect(list.first.id, 42);
      expect(list.first.leida, true);
    });
  });
}
