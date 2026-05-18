import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String? merchant;
  final double? amount;
  final DateTime? date;
  final String rawText;

  OcrResult({
    this.merchant,
    this.amount,
    this.date,
    required this.rawText,
  });
}

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final text = recognizedText.text;

    return _parseOcrText(text);
  }

  OcrResult _parseOcrText(String text) {
    double? amount;
    DateTime? date;
    String? merchant;

    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (lines.isNotEmpty) {
      // Heurística simple: la primera línea suele ser el nombre del comercio.
      merchant = lines.first;
      if (merchant.length < 3 && lines.length > 1) {
        merchant = lines[1];
      }
    }

    // Buscar monto: soporta "TOTAL", "IMPORTE", "MONTO", "PAGO", etc.
    final amountRegex = RegExp(
      r'(?:TOTAL|IMPORTE|MONTO|NETO|PAGO|CARGADO)\s*(?:S/|\$|USD)?\s*[:=\-]?\s*(\d{1,5}(?:[.,]\d{2})?)',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      
      if (amount == null) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          final amountStr = match.group(1)?.replaceAll(',', '.');
          if (amountStr != null) {
            amount = double.tryParse(amountStr);
          }
        }
      }
      
      // Buscar fecha
      if (date == null) {
        final dateRegex = RegExp(r'(\d{2})[-/](\d{2})[-/](\d{2,4})');
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) {
          final day = int.tryParse(dateMatch.group(1)!) ?? 1;
          final month = int.tryParse(dateMatch.group(2)!) ?? 1;
          int year = int.tryParse(dateMatch.group(3)!) ?? DateTime.now().year;
          if (year < 100) year += 2000;
          
          try {
            date = DateTime(year, month, day);
          } catch (_) {}
        }
      }
    }

    // Fallback: Si no encuentra la palabra TOTAL, busca el número más grande con decimales
    if (amount == null) {
      final fallbackRegex = RegExp(r'(?:S/|\$)?\s*(\d{1,4}[.,]\d{2})');
      double maxAmount = 0;
      for (final line in lines) {
        final matches = fallbackRegex.allMatches(line);
        for (final match in matches) {
          final valStr = match.group(1)?.replaceAll(',', '.');
          if (valStr != null) {
            final val = double.tryParse(valStr);
            if (val != null && val > maxAmount) {
              maxAmount = val;
            }
          }
        }
      }
      if (maxAmount > 0) amount = maxAmount;
    }

    return OcrResult(
      merchant: merchant,
      amount: amount,
      date: date,
      rawText: text,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
