import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/budget.dart';

class BudgetRepository {
  final ApiClient apiClient;

  BudgetRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<Budget> createBudget({
    required double montoBase,
    required int mes,
    required int anio,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/budgets/',
        data: {
          'monto_base': montoBase,
          'mes': mes,
          'año': anio, // El backend espera 'año' con 'ñ'
        },
      );
      return Budget.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<BudgetSummary> fetchCurrentBudget() async {
    try {
      final response = await apiClient.dio.get('/api/budgets/current');
      return BudgetSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Budget> addIncome({
    required double monto,
    required String descripcion,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/budgets/income',
        data: {
          'monto': monto,
          'descripcion': descripcion,
        },
      );
      return Budget.fromJson(response.data as Map<String, dynamic>);
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
    return 'Error en la solicitud de presupuesto.';
  }
}
