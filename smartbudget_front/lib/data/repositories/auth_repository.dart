import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : apiClient = apiClient ?? ApiClient(),
      tokenStorage = tokenStorage ?? TokenStorage();

  Future<TokenResponse> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final tokenResponse = TokenResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      await tokenStorage.saveToken(tokenResponse.accessToken);

      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<UserResponse> register(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {'nombre': nombre, 'email': email, 'password': password},
      );

      return UserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<UserResponse> fetchProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/profile');

      return UserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> logout() async {
    await tokenStorage.deleteToken();
  }

  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message != null) return message.toString();
    }

    if (statusCode == 401) {
      return 'Credenciales incorrectas o sesión expirada.';
    }

    if (statusCode == 422) {
      return 'Datos inválidos. Verifica la información ingresada.';
    }

    if (statusCode == 500) {
      return 'Error interno del servidor.';
    }

    return 'No se pudo completar la solicitud.';
  }
}
