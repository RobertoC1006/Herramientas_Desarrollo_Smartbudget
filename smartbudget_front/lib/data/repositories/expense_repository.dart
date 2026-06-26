import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/transaction.dart';

class ExpenseRepository {
  final ApiClient apiClient;

  ExpenseRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<TransactionItem>> fetchExpenses({
    int? mes,
    int? anio,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (mes != null) queryParameters['mes'] = mes;
      if (anio != null) queryParameters['año'] = anio; // El backend espera 'año'

      final response = await apiClient.dio.get(
        '/api/expenses/',
        queryParameters: queryParameters,
      );

      final list = response.data as List<dynamic>;
      return list
          .map((json) => TransactionItem.fromExpenseJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<TransactionItem> createExpense({
    required String categoria,
    required double monto,
    String? descripcion,
    String? comercio,
    required DateTime fecha,
    String fuente = 'manual',
  }) async {
    try {
      // Formatear la fecha como YYYY-MM-DD
      final fechaStr = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      
      final response = await apiClient.dio.post(
        '/api/expenses/',
        data: {
          'categoria': TransactionItem.mapFrontendCategoryToBackend(categoria),
          'monto': monto,
          'descripcion': descripcion,
          'comercio': comercio,
          'fecha': fechaStr,
          'fuente': fuente.toLowerCase(),
        },
      );

      return TransactionItem.fromExpenseJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await apiClient.dio.delete('/api/expenses/$id');
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
    return 'Error en la solicitud de gastos.';
  }
}
