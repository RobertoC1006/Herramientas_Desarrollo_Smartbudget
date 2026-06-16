import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/goal.dart';

class GoalRepository {
  final ApiClient apiClient;

  GoalRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<Goal>> fetchGoals() async {
    try {
      final response = await apiClient.dio.get('/api/goals/');
      final list = response.data as List<dynamic>;
      return list.map((json) => Goal.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Goal> createGoal(String name, double targetAmount) async {
    try {
      final response = await apiClient.dio.post(
        '/api/goals/',
        data: {
          'nombre': name,
          'monto_objetivo': targetAmount,
        },
      );
      return Goal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> contributeToGoal(int goalId, double amount) async {
    try {
      await apiClient.dio.post(
        '/api/goals/$goalId/contribute',
        data: {
          'monto': amount,
        },
      );
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
    return 'Error en la solicitud de metas de ahorro.';
  }
}
