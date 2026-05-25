import 'package:dio/dio.dart';

import 'token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({Dio? dio, TokenStorage? tokenStorage})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'http://localhost:8000',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
      tokenStorage = tokenStorage ?? const TokenStorage() {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.tokenStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
