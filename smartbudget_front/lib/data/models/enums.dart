enum CategoriaGasto {
  alimentacion,
  transporte,
  educacion,
  salud,
  ropa,
  entretenimiento,
  servicios,
  vivienda,
  otros,
}

enum FuenteGasto { manual, ocrImagen, ocrPdf }

enum EstadoMeta { enProgreso, completada, cancelada }

enum TipoContribucionMeta { aporte, retiro }

enum TipoAlerta { informativa, advertencia, critica, motivacional }

String categoriaGastoToJson(CategoriaGasto value) {
  return value.name;
}

CategoriaGasto categoriaGastoFromJson(String value) {
  return CategoriaGasto.values.firstWhere(
    (item) => item.name == value,
    orElse: () => CategoriaGasto.otros,
  );
}

String fuenteGastoToJson(FuenteGasto value) {
  switch (value) {
    case FuenteGasto.manual:
      return 'manual';
    case FuenteGasto.ocrImagen:
      return 'ocr_imagen';
    case FuenteGasto.ocrPdf:
      return 'ocr_pdf';
  }
}

FuenteGasto fuenteGastoFromJson(String value) {
  switch (value) {
    case 'ocr_imagen':
      return FuenteGasto.ocrImagen;
    case 'ocr_pdf':
      return FuenteGasto.ocrPdf;
    case 'manual':
    default:
      return FuenteGasto.manual;
  }
}

String estadoMetaToJson(EstadoMeta value) {
  switch (value) {
    case EstadoMeta.enProgreso:
      return 'en_progreso';
    case EstadoMeta.completada:
      return 'completada';
    case EstadoMeta.cancelada:
      return 'cancelada';
  }
}

EstadoMeta estadoMetaFromJson(String value) {
  switch (value) {
    case 'completada':
      return EstadoMeta.completada;
    case 'cancelada':
      return EstadoMeta.cancelada;
    case 'en_progreso':
    default:
      return EstadoMeta.enProgreso;
  }
}

String tipoContribucionMetaToJson(TipoContribucionMeta value) {
  return value.name;
}

TipoContribucionMeta tipoContribucionMetaFromJson(String value) {
  switch (value) {
    case 'retiro':
      return TipoContribucionMeta.retiro;
    case 'aporte':
    default:
      return TipoContribucionMeta.aporte;
  }
}

String tipoAlertaToJson(TipoAlerta value) {
  return value.name;
}

TipoAlerta tipoAlertaFromJson(String value) {
  switch (value) {
    case 'advertencia':
      return TipoAlerta.advertencia;
    case 'critica':
      return TipoAlerta.critica;
    case 'motivacional':
      return TipoAlerta.motivacional;
    case 'informativa':
    default:
      return TipoAlerta.informativa;
  }
}
