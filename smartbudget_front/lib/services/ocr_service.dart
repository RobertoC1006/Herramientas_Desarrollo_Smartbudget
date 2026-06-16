import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/api_client.dart';

class OcrResult {
  final String? merchant;
  final double? amount;
  final DateTime? date;
  final String rawText;
  final String? category;
  final String? description;
  final double? confidence;

  OcrResult({
    this.merchant,
    this.amount,
    this.date,
    required this.rawText,
    this.category,
    this.description,
    this.confidence,
  });
}

class OcrService {
  final ApiClient apiClient;

  OcrService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<OcrResult> processImage(Uint8List bytes, String fileName) async {
    try {
      // Determinar content-type basado en la extensión
      String contentType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      } else if (fileName.toLowerCase().endsWith('.pdf')) {
        contentType = 'application/pdf';
      }

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      final response = await apiClient.dio.post(
        '/api/expenses/scan',
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      
      // Parsear la respuesta estructurada de la IA del backend
      final monto = data['monto'] != null ? (data['monto'] as num).toDouble() : null;
      final comercio = data['comercio'] as String?;
      final categoria = data['categoria'] as String?;
      final descripcion = data['descripcion'] as String?;
      final confianza = data['confianza'] != null ? (data['confianza'] as num).toDouble() : 0.0;
      
      DateTime? fecha;
      if (data['fecha'] != null) {
        try {
          fecha = DateTime.parse(data['fecha'] as String);
        } catch (_) {}
      }

      return OcrResult(
        merchant: comercio,
        amount: monto,
        date: fecha,
        rawText: response.toString(),
        category: categoria != null ? _mapBackendCategoryToFrontend(categoria) : null,
        description: descripcion,
        confidence: confianza,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['detail'] ?? data['error'];
        if (message != null) throw Exception(message.toString());
      }
      throw Exception('Error al conectar con el servicio de OCR.');
    }
  }

  static String? _mapBackendCategoryToFrontend(String backendCategory) {
    switch (backendCategory.toLowerCase()) {
      case 'comida':
        return 'Comida';
      case 'transporte':
      case 'viajes':
        return 'Transporte';
      case 'ocio':
        return 'Ocio';
      case 'salud':
        return 'Salud';
      case 'educacion':
        return 'Educación';
      case 'ropa':
      case 'tecnologia':
        return 'Compras';
      case 'hogar':
        return 'Servicios';
      case 'otros':
      default:
        return 'Otros';
    }
  }

  void dispose() {
    // Método vacío mantenido para compatibilidad con add_expense_page.dart
  }
}
