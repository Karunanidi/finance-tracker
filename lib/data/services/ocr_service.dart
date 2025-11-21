import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_service.g.dart';

@riverpod
OcrService ocrService(Ref ref) {
  return OcrService();
}

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ParsedReceipt?> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    return _parseText(recognizedText.text);
  }

  ParsedReceipt _parseText(String text) {
    // Simple heuristic parsing
    // 1. Find potential total amount (largest number with currency symbol or just largest number)
    // 2. Find date
    
    double? amount;
    DateTime? date;
    String? merchant;

    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      merchant = lines.first; // Assumption: First line is often merchant name
    }

    // Regex for money (e.g., $10.00, 10.00, 1,000.00)
    final amountRegex = RegExp(r'\d{1,3}(,\d{3})*(\.\d{2})?');
    
    double maxAmount = 0.0;
    
    for (var line in lines) {
      // Try to find date
      // ... (Date parsing logic can be complex, simplified here)
      
      // Try to find amount
      final matches = amountRegex.allMatches(line);
      for (var match in matches) {
        final valStr = match.group(0)?.replaceAll(',', '');
        if (valStr != null) {
          final val = double.tryParse(valStr);
          if (val != null && val > maxAmount) {
            maxAmount = val;
          }
        }
      }
    }
    
    amount = maxAmount > 0 ? maxAmount : null;

    return ParsedReceipt(
      merchant: merchant,
      amount: amount,
      date: date ?? DateTime.now(),
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class ParsedReceipt {
  final String? merchant;
  final double? amount;
  final DateTime date;

  ParsedReceipt({this.merchant, this.amount, required this.date});
}
