class SmartScoreSnapshot {
  final int id;
  final int userId;
  final int budgetId;
  final int score;
  final int mes;
  final int anio;
  final Map<String, dynamic>? desglose;
  final DateTime calculadoEn;

  const SmartScoreSnapshot({
    required this.id,
    this.userId = 0,
    this.budgetId = 0,
    required this.score,
    required this.mes,
    required this.anio,
    this.desglose,
    required this.calculadoEn,
  });

  factory SmartScoreSnapshot.fromJson(Map<String, dynamic> json) {
    // El backend puede enviar fecha_calculo (en SnapshotHistoryResponse) o calculado_en
    final fechaStr = json['fecha_calculo'] ?? json['calculado_en'] ?? DateTime.now().toIso8601String();
    final fecha = DateTime.parse(fechaStr as String);

    return SmartScoreSnapshot(
      id: json['id'] as int,
      userId: (json['user_id'] as int?) ?? 0,
      budgetId: (json['budget_id'] as int?) ?? 0,
      score: json['score'] as int,
      mes: json['mes'] as int? ?? fecha.month,
      anio: json['anio'] as int? ?? fecha.year,
      desglose: json['desglose'] == null
          ? null
          : Map<String, dynamic>.from(json['desglose'] as Map),
      calculadoEn: fecha,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'budget_id': budgetId,
      'score': score,
      'mes': mes,
      'anio': anio,
      'desglose': desglose,
      'calculado_en': calculadoEn.toIso8601String(),
    };
  }
}
