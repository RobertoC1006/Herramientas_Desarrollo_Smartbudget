class Budget {
  final int id;
  final int userId;
  final int mes;
  final int anio;
  final double montoBase;
  final double ingresosAdicionales;
  final double totalGastado;
  final double saldoDisponible;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.mes,
    required this.anio,
    required this.montoBase,
    required this.ingresosAdicionales,
    required this.totalGastado,
    required this.saldoDisponible,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      mes: json['mes'] as int,
      anio: (json['anio'] ?? json['año']) as int,
      montoBase: (json['monto_base'] as num).toDouble(),
      ingresosAdicionales: (json['ingresos_adicionales'] as num).toDouble(),
      totalGastado: (json['total_gastado'] as num).toDouble(),
      saldoDisponible: (json['saldo_disponible'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mes': mes,
      'anio': anio,
      'monto_base': montoBase,
      'ingresos_adicionales': ingresosAdicionales,
      'total_gastado': totalGastado,
      'saldo_disponible': saldoDisponible,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
