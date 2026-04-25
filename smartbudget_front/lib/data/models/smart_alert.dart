import 'enums.dart';

class SmartAlert {
  final int id;
  final int userId;
  final TipoAlerta tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime createdAt;

  const SmartAlert({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      tipo: tipoAlertaFromJson(json['tipo'] as String),
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      leida: json['leida'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tipo': tipoAlertaToJson(tipo),
      'titulo': titulo,
      'mensaje': mensaje,
      'leida': leida,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
