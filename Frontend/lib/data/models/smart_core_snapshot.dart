class SmartScoreSnapshot {
  final int id;
  final int userId;
  final int budgetId;
  final int score;
  final Map<String, dynamic>? desglose;
  final DateTime calculadoEn;

  const SmartScoreSnapshot({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.score,
    this.desglose,
    required this.calculadoEn,
  });

  factory SmartScoreSnapshot.fromJson(Map<String, dynamic> json) {
    return SmartScoreSnapshot(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      budgetId: json['budget_id'] as int,
      score: json['score'] as int,
      desglose: json['desglose'] == null
          ? null
          : Map<String, dynamic>.from(json['desglose'] as Map),
      calculadoEn: DateTime.parse(json['calculado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'budget_id': budgetId,
      'score': score,
      'desglose': desglose,
      'calculado_en': calculadoEn.toIso8601String(),
    };
  }
}
