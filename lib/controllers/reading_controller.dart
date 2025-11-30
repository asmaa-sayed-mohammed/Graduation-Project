import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/services/connectivity_service.dart';

// Model for meter reading blocks
class MeterReading {
  final String value;
  final String? unit;
  final double confidence;
  final Rect position;
  final double left;

  MeterReading({
    required this.value,
    this.unit,
    required this.confidence,
    required this.position,
    required this.left,
  });
}

class ReadingController extends GetxController {
  final connectivityService = ConnectivityService();
  final supabase = Supabase.instance.client;

  var pickedImage = Rxn<File>();
  var recognizedText = ''.obs;
  var isLoading = false.obs;
  var isListening = false.obs;
  var recognizedVoiceText = ''.obs;
  var finalText = ''.obs;

  late final TextEditingController textController;
  late final TextEditingController oldReadingController;
  late final TextEditingController newReadingController;

  final picker = ImagePicker();
  final stt.SpeechToText speech = stt.SpeechToText();
  late final TextRecognizer textRecognizer;

  String? savedOldReading;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    oldReadingController = TextEditingController();
    newReadingController = TextEditingController();

    textRecognizer = TextRecognizer(
      script: TextRecognitionScript.values.firstWhere(
        (e) => e.name == 'arabic',
        orElse: () => TextRecognitionScript.latin,
      ),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    oldReadingController.dispose();
    newReadingController.dispose();
    textRecognizer.close();
    super.onClose();
  }

  // ------------------ Supabase ------------------

  Future<void> loadLastReading(String userId) async {
    final response = await supabase
        .from('usage_record')
        .select('reading')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      oldReadingController.text = (response['reading'] as num).toString();
    }
  }

  Future<void> saveReadingToSupabase({required String userId}) async {
    final result = calculateManualResult();

    if (result['error'] == true) return;

    try {
      await supabase.from('usage_record').insert({
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'reading': (result['newReading'] as double).toInt(), // int8
        'price': (result['totalPrice'] as double).toInt(), // int4
      });
      Get.snackbar(
        'تم الحفظ',
        'تم حفظ القراءة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حفظ القراءة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // ------------------ Manual Reading Helpers ------------------

  double _parseReading(String input) {
    if (input.trim().isEmpty) return 0.0;
    String cleaned = convertArabicDigitsToEnglish(input.trim());
    cleaned = cleaned.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String? validateManualInputs() {
    final oldVal = _parseReading(oldReadingController.text);
    final newVal = _parseReading(newReadingController.text);

    if (oldReadingController.text.trim().isEmpty ||
        newReadingController.text.trim().isEmpty) {
      return 'الرجاء إدخال القراءة القديمة والقراءة الجديدة';
    }
    if (newVal <= oldVal) {
      return 'القراءة الجديدة يجب أن تكون أكبر من القديمة';
    }
    return null;
  }

  double calculateManualConsumption() {
    final oldVal = _parseReading(oldReadingController.text);
    final newVal = _parseReading(newReadingController.text);
    if (newVal <= oldVal) return 0.0;
    return double.parse((newVal - oldVal).toStringAsFixed(3));
  }

  double calculateCostFromKwh(double kwh) {
    double cost = 0.0;
    if (kwh <= 50) {
      cost = kwh * 0.68;
    } else if (kwh <= 100) {
      cost = (50 * 0.68) + ((kwh - 50) * 0.78);
    } else if (kwh <= 200) {
      cost = (50 * 0.68) + (50 * 0.78) + ((kwh - 100) * 0.95);
    } else if (kwh <= 350) {
      cost = (50 * 0.68) + (50 * 0.78) + (100 * 0.95) + ((kwh - 200) * 1.55);
    } else if (kwh <= 650) {
      cost =
          (50 * 0.68) +
          (50 * 0.78) +
          (100 * 0.95) +
          (150 * 1.55) +
          ((kwh - 350) * 1.95);
    } else if (kwh <= 1000) {
      cost =
          (50 * 0.68) +
          (50 * 0.78) +
          (100 * 0.95) +
          (150 * 1.55) +
          (300 * 1.95) +
          ((kwh - 650) * 2.10);
    } else {
      cost =
          (50 * 0.68) +
          (50 * 0.78) +
          (100 * 0.95) +
          (150 * 1.55) +
          (300 * 1.95) +
          (350 * 2.10) +
          ((kwh - 1000) * 2.23) + 20;
    }

    return double.parse(cost.toStringAsFixed(2));
  }

  Map<String, dynamic> _determineTier(double kwh) {
    if (kwh <= 50) return {'tier': 1, 'pricePerKwh': 0.68};
    if (kwh <= 100) return {'tier': 2, 'pricePerKwh': 0.78};
    if (kwh <= 200) return {'tier': 3, 'pricePerKwh': 0.95};
    if (kwh <= 350) return {'tier': 4, 'pricePerKwh': 1.55};
    if (kwh <= 650) return {'tier': 5, 'pricePerKwh': 1.95};
    if (kwh <= 1000) return {'tier': 6, 'pricePerKwh': 2.10};
    return {'tier': 7, 'pricePerKwh': 2.23};
  }

  Map<String, dynamic> calculateManualResult() {
    final error = validateManualInputs();
    if (error != null) return {'error': true, 'message': error};

    final oldVal = _parseReading(oldReadingController.text);
    final newVal = _parseReading(newReadingController.text);
    final consumption = double.parse((newVal - oldVal).toStringAsFixed(3));
    final totalPrice = calculateCostFromKwh(consumption);
    final tierInfo = _determineTier(consumption);

    return {
      'error': false,
      'oldReading': oldVal,
      'newReading': newVal,
      'consumption': consumption,
      'pricePerKwh': tierInfo['pricePerKwh'],
      'tier': tierInfo['tier'],
      'totalPrice': totalPrice,
    };
  }

  void clearManualInputs() {
    oldReadingController.clear();
    newReadingController.clear();
  }

  // ------------------ OCR / Image ------------------

  Future<void> pickImage(
    ImageSource source,
    TextEditingController targetController,
  ) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
        recognizedText.value = '';
        await recognizeText(pickedImage.value!, targetController);
      }
    } catch (e) {
      _showPhotoTip(
        'خطأ في اختيار الصورة',
        'تأكد من صلاحيات الكاميرا أو المعرض.',
      );
    }
  }

  Future<void> recognizeText(
    File image,
    TextEditingController targetController,
  ) async {
    isLoading.value = true;
    recognizedText.value = '';

    try {
      final inputImage = InputImage.fromFile(image);
      final result = await textRecognizer.processImage(inputImage);

      final Uint8List imageBytes = image.readAsBytesSync();
      final imageData = await decodeImageFromList(imageBytes);
      final imageWidth = imageData.width.toDouble();
      final imageHeight = imageData.height.toDouble();

      List<MeterReading> digitBlocks = [];
      final digitRegex = RegExp(r'[\d٠١٢٣٤٥٦٧٨٩]+(\.[\d٠١٢٣٤٥٦٧٨٩]{1,3})?');
      final meterModelRegex = RegExp(
        r'(GGIE|CG61E|82E|B2E|CG61|عداد كهرباء)',
        caseSensitive: false,
      );

      for (final block in result.blocks) {
        final blockY = block.boundingBox.top;
        final blockX = block.boundingBox.left;
        final fullBlockText = block.text.toLowerCase();

        if (blockY < imageHeight * 0.8 &&
            block.boundingBox.height > imageHeight * 0.02 &&
            digitRegex.hasMatch(block.text)) {
          String text = convertArabicDigitsToEnglish(block.text);
          final matches = digitRegex.allMatches(text);

          for (final match in matches) {
            String cleanNumber = match
                .group(0)!
                .replaceAll(RegExp(r'[^\d.]'), '');
            if (cleanNumber.isEmpty) continue;

            double confidence = 0.0;
            confidence +=
                (blockX - (imageWidth * 0.5)).abs() < (imageWidth * 0.3)
                ? 0.2
                : 0;
            confidence += blockY < imageHeight * 0.5 ? 0.2 : 0.1;
            confidence += (cleanNumber.length >= 2 ? 0.2 : 0.1);
            if (meterModelRegex.hasMatch(fullBlockText)) confidence += 0.3;
            confidence = confidence.clamp(0.0, 1.0);

            digitBlocks.add(
              MeterReading(
                value: cleanNumber,
                unit: null,
                confidence: confidence,
                position: block.boundingBox,
                left: blockX,
              ),
            );
          }
        }
      }

      digitBlocks.sort((a, b) => a.left.compareTo(b.left));
      final mergedReadings = _mergeDigitBlocks(digitBlocks, imageWidth);

      if (mergedReadings.isNotEmpty) {
        mergedReadings.sort((a, b) => b.confidence.compareTo(a.confidence));
        final best = mergedReadings.first;
        final cleaned = removeLeadingZeros(best.value);
        targetController.text = cleaned;
        recognizedText.value = '$cleaned kWh';
        finalText.value = '$cleaned kWh';
      } else {
        _showPhotoTip(
          'لا يوجد رقم صالح في الصورة',
          'حاول التقاط صورة أقرب وأوضح للعداد.',
        );
      }
    } catch (e) {
      _showPhotoTip(
        'خطأ في معالجة الصورة',
        'تأكد من وضوح الصورة وجودة الإضاءة.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<MeterReading> _mergeDigitBlocks(
    List<MeterReading> blocks,
    double imageWidth,
  ) {
    if (blocks.isEmpty) return [];
    List<MeterReading> merged = [];
    List<MeterReading> current = [blocks.first];
    double lastRight = blocks.first.position.right;

    for (int i = 1; i < blocks.length; i++) {
      final block = blocks[i];
      if ((block.left - lastRight) < imageWidth * 0.02) {
        current.add(block);
        lastRight = block.position.right;
      } else {
        merged.add(_concatGroup(current));
        current = [block];
        lastRight = block.position.right;
      }
    }
    merged.add(_concatGroup(current));
    return merged.where((r) => r.value.length >= 4).toList();
  }

  MeterReading _concatGroup(List<MeterReading> group) {
    String val = group.map((b) => b.value).join();
    double avgConf =
        group.map((b) => b.confidence).reduce((a, b) => a + b) / group.length;
    return MeterReading(
      value: val,
      unit: 'kWh',
      confidence: avgConf,
      position: group.first.position,
      left: group.first.left,
    );
  }

  void _showPhotoTip(String title, String message) {
    recognizedText.value = '';
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }

  String removeLeadingZeros(String number) {
    if (number.contains('.')) {
      final parts = number.split('.');
      final integerPart = int.parse(parts[0]).toString();
      final decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');
      return decimalPart.isEmpty ? integerPart : '$integerPart.$decimalPart';
    } else {
      return int.parse(number).toString();
    }
  }

  String convertArabicDigitsToEnglish(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < arabicDigits.length; i++) {
      input = input.replaceAll(arabicDigits[i], i.toString());
    }
    return input;
  }

  // ------------------ Voice ------------------

  Future<void> recognizeVoice(
    TextEditingController targetController, {
    bool append = false,
  }) async {
    bool hasInternet = await connectivityService.connected();
    if (!hasInternet) {
      Get.snackbar(
        'لا يوجد اتصال بالإنترنت',
        'من فضلك اتصل بالإنترنت لاستخدام التعرف على الصوت',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening')
            isListening.value = false;
        },
        onError: (error) {
          isListening.value = false;
          _showVoiceTip('خطأ في التعرف على الصوت', error.errorMsg);
        },
      );

      if (!available) {
        _showVoiceTip(
          'خاصية الصوت غير متاحة',
          'جرب على جهاز حقيقي أو تحقق من الصلاحيات.',
        );
        return;
      }

      isListening.value = true;
      recognizedVoiceText.value = append ? recognizedVoiceText.value : '';

      await speech.listen(
        localeId: 'ar-EG',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        onResult: (result) {
          recognizedVoiceText.value = cleanText(result.recognizedWords);
          if (result.finalResult) {
            final double number = _parseInput(recognizedVoiceText.value);
            final displayValue = _formatNumber(number);
            targetController.text = displayValue;
            recognizedText.value = '$displayValue kWh';
            finalText.value = '$displayValue kWh';
          }
        },
      );
    } catch (e) {
      isListening.value = false;
      _showVoiceTip('خطأ غير متوقع في التعرف على الصوت', e.toString());
    }
  }

  void _showVoiceTip(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\u0621-\u064A0-9\s.]'), ' ')
        .replaceAll('،', ' ')
        .replaceAll('؟', '')
        .trim();
  }

  double _parseInput(String input) {
    String numericStr = input.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericStr) ?? extractArabicNumber(input);
  }

  String _formatNumber(double number) {
    if (number == number.toInt().toDouble()) return number.toInt().toString();
    return number
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void processInput() {
    String input = '';
    if (textController.text.isNotEmpty)
      input = cleanText(textController.text);
    else if (recognizedVoiceText.value.isNotEmpty)
      input = cleanText(recognizedVoiceText.value);
    else if (recognizedText.value.isNotEmpty)
      input = recognizedText.value
          .replaceAll(
            RegExp(r'\s*(kWh|kW|كيلو وات ساعة|وات ساعة|ساعة|kwh|kw|وات)'),
            '',
          )
          .trim();

    if (input.isNotEmpty) {
      final double number = _parseInput(input);
      final displayValue = _formatNumber(number);
      finalText.value = '$displayValue kWh';
    }
  }

  double extractArabicNumber(String text) {
    final arabicDigits = RegExp(r'[٠-٩]');
    final matches = arabicDigits.allMatches(text);
    if (matches.isEmpty) return 0.0;
    String numeric = '';
    for (final m in matches)
      numeric += (m.group(0)!.codeUnitAt(0) - 0x0660).toString();
    return double.tryParse(numeric) ?? 0.0;
  }
}
