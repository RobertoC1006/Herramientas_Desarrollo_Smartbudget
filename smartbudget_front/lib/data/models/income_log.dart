class IncomeLog {
  final int id;
  final int userId;
  final int budgetId;
  final double monto;
  final String? descripcion;
  final DateTime fecha;

  const IncomeLog({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.monto,
    this.descripcion,
    required this.fecha,
  });

  factory IncomeLog.fromJson(Map<String, dynamic> json) {
    return IncomeLog(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      budgetId: json['budget_id'] as int,
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'budget_id': budgetId,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String().split('T').first,
    };
  }
}
