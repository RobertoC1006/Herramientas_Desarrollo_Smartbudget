class Budget {
  final int id;
  final int userId;
  final int mes;
  final int anio;
  final double montoBase;
  final double ingresosAdicionales;
  final double totalGastado;
  final double saldoDisponible;

  const Budget({
    required this.id,
    required this.userId,
    required this.mes,
    required this.anio,
    required this.montoBase,
    required this.ingresosAdicionales,
    required this.totalGastado,
    required this.saldoDisponible,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      mes: json['mes'] as int,
      anio: json['anio'] as int,
      montoBase: (json['monto_base'] as num).toDouble(),
      ingresosAdicionales: (json['ingresos_adicionales'] as num).toDouble(),
      totalGastado: (json['total_gastado'] as num).toDouble(),
      saldoDisponible: (json['saldo_disponible'] as num).toDouble(),
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
    };
  }
}

class BudgetSummary {
  final double saldoDisponible;
  final double totalGastado;
  final double montoBase;
  final double ingresosAdicionales;
  final double porcentajeGastado;
  final int mes;
  final int anio;
  final String simbolo;

  const BudgetSummary({
    required this.saldoDisponible,
    required this.totalGastado,
    required this.montoBase,
    required this.ingresosAdicionales,
    required this.porcentajeGastado,
    required this.mes,
    required this.anio,
    required this.simbolo,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      saldoDisponible: (json['saldo_disponible'] as num).toDouble(),
      totalGastado: (json['total_gastado'] as num).toDouble(),
      montoBase: (json['monto_base'] as num).toDouble(),
      ingresosAdicionales: (json['ingresos_adicionales'] as num).toDouble(),
      porcentajeGastado: (json['porcentaje_gastado'] as num).toDouble(),
      mes: json['mes'] as int,
      anio: json['anio'] as int,
      simbolo: json['simbolo'] as String? ?? 'S/.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saldo_disponible': saldoDisponible,
      'total_gastado': totalGastado,
      'monto_base': montoBase,
      'ingresos_adicionales': ingresosAdicionales,
      'porcentaje_gastado': porcentajeGastado,
      'mes': mes,
      'anio': anio,
      'simbolo': simbolo,
    };
  }
}
