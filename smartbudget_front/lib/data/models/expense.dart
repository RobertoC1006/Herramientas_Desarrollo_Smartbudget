import 'enums.dart';

class Expense {
  final int id;
  final int userId;
  final int budgetId;
  final CategoriaGasto categoria;
  final double monto;
  final String? descripcion;
  final String? comercio;
  final DateTime fecha;
  final FuenteGasto fuente;
  final double? ocrConfianza;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.categoria,
    required this.monto,
    this.descripcion,
    this.comercio,
    required this.fecha,
    required this.fuente,
    this.ocrConfianza,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      budgetId: json['budget_id'] as int,
      categoria: categoriaGastoFromJson(json['categoria'] as String),
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      comercio: json['comercio'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      fuente: fuenteGastoFromJson(json['fuente'] as String? ?? 'manual'),
      ocrConfianza: json['ocr_confianza'] == null
          ? null
          : (json['ocr_confianza'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'budget_id': budgetId,
      'categoria': categoriaGastoToJson(categoria),
      'monto': monto,
      'descripcion': descripcion,
      'comercio': comercio,
      'fecha': fecha.toIso8601String().split('T').first,
      'fuente': fuenteGastoToJson(fuente),
      'ocr_confianza': ocrConfianza,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
