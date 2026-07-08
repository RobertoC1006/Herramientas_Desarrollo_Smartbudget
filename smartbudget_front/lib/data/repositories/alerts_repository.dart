import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/smart_alert.dart';

class AlertsRepository {
  final ApiClient apiClient;

  AlertsRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<SmartAlert>> fetchAlerts() async {
    try {
      final response = await apiClient.dio.get('/api/alerts/');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => SmartAlert.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> triggerGenerateAlerts() async {
    try {
      await apiClient.dio.post('/api/alerts/generate');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<SmartAlert> markAsRead(int alertId) async {
    try {
      final response = await apiClient.dio.put('/api/alerts/$alertId/read');
      return SmartAlert.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message != null) return message.toString();
    }
    return 'Error en la solicitud de alertas.';
  }
}
