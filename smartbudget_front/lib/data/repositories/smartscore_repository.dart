import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/smart_core_snapshot.dart';

class SmartScoreRepository {
  final ApiClient apiClient;

  SmartScoreRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<int> fetchCurrentScore() async {
    try {
      final response = await apiClient.dio.get('/api/smartscore/');
      final data = response.data as Map<String, dynamic>;
      return data['score'] as int? ?? 0;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<SmartScoreSnapshot>> fetchHistory({int meses = 6}) async {
    try {
      final response = await apiClient.dio.get(
        '/api/smartscore/history',
        queryParameters: {'meses': meses},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((json) => SmartScoreSnapshot.fromJson(json as Map<String, dynamic>))
          .toList();
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
    return 'Error en la solicitud de SmartScore.';
  }
}
