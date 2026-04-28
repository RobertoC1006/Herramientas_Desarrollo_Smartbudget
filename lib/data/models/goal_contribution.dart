import 'enums.dart';

class GoalContribution {
  final int id;
  final int goalId;
  final int userId;
  final double monto;
  final TipoContribucionMeta tipo;
  final DateTime fecha;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.monto,
    required this.tipo,
    required this.fecha,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as int,
      goalId: json['goal_id'] as int,
      userId: json['user_id'] as int,
      monto: (json['monto'] as num).toDouble(),
      tipo: tipoContribucionMetaFromJson(json['tipo'] as String),
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'user_id': userId,
      'monto': monto,
      'tipo': tipoContribucionMetaToJson(tipo),
      'fecha': fecha.toIso8601String(),
    };
  }
}
