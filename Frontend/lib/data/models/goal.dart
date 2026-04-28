import 'enums.dart';

class Goal {
  final int id;
  final int userId;
  final String nombre;
  final String? descripcion;
  final double montoObjetivo;
  final double saldoAcumulado;
  final EstadoMeta estado;
  final DateTime? fechaLimite;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.nombre,
    this.descripcion,
    required this.montoObjetivo,
    required this.saldoAcumulado,
    required this.estado,
    this.fechaLimite,
    required this.createdAt,
    this.completedAt,
  });

  double get progreso {
    if (montoObjetivo <= 0) return 0;
    return saldoAcumulado / montoObjetivo;
  }

  bool get estaCompletada {
    return estado == EstadoMeta.completada || saldoAcumulado >= montoObjetivo;
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      montoObjetivo: (json['monto_objetivo'] as num).toDouble(),
      saldoAcumulado: (json['saldo_acumulado'] as num).toDouble(),
      estado: estadoMetaFromJson(json['estado'] as String? ?? 'en_progreso'),
      fechaLimite: json['fecha_limite'] == null
          ? null
          : DateTime.parse(json['fecha_limite'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre': nombre,
      'descripcion': descripcion,
      'monto_objetivo': montoObjetivo,
      'saldo_acumulado': saldoAcumulado,
      'estado': estadoMetaToJson(estado),
      'fecha_limite': fechaLimite?.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
