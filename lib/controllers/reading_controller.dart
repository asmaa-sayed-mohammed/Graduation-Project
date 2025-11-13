import 'dart:io';
import 'dart:typed_data'; // For handling image bytes in decodeImageFromList
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart'; // For decodeImageFromList to get image dimensions
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:graduation_project/services/connectivity_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Class to store meter reading information extracted from OCR blocks
// Stores the numeric value, optional unit, confidence score, and position for potential rendering or debugging
class MeterReading {
  final String value; // The cleaned numeric reading (e.g., '12345.6')
  final String? unit; // Optional unit like 'kWh' after normalization
  final double confidence; // Score from 0.0 to 1.0 based on position, length, etc.
  final Rect position; // Bounding box for the detected text block
  final double left; // Extracted left position for sorting

  MeterReading({
    required this.value,
    this.unit,
    required this.confidence,
    required this.position,
    required this.left,
  });
}

// Controller for handling meter reading inputs via image OCR, voice recognition, or manual text
// Uses GetX for state management and reactive observables
class ReadingController extends GetxController {

  final connectivityService = ConnectivityService(); // For checking internet connectivity
  // Reactive variables for UI state updates
  var pickedImage = Rxn<File>(); // Currently picked image file (nullable reactive)
  var recognizedText = ''.obs; // Final displayed text next to the number (e.g., '12345 kWh')
  var isLoading = false.obs; // Loading indicator for OCR processing
  var isListening = false.obs; // Listening state for voice recognition
  var recognizedVoiceText = ''.obs; // Raw text from voice recognition
  var finalText = ''.obs; // Processed final output with unit (e.g., '12345 kWh')

  // Controllers and services
  late final TextEditingController textController; // For manual text input
  final picker = ImagePicker(); // Service for selecting images from camera/gallery
  final stt.SpeechToText speech = stt.SpeechToText(); // Voice recognition service
  late final TextRecognizer textRecognizer; // OCR recognizer for text extraction

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController(); // Initialize text controller

    // Initialize OCR recognizer preferring Arabic script for better handling of Arabic digits and text
    // Fallback to Latin if Arabic is unavailable
    textRecognizer = TextRecognizer(script: TextRecognitionScript.values.firstWhere(
          (e) => e.name == 'arabic',
      orElse: () => TextRecognitionScript.latin,
    ));
  }

  @override
  void onClose() {
    // Proper disposal to prevent memory leaks
    textController.dispose();
    textRecognizer.close(); // Release OCR resources
    super.onClose();
  }

  // Method to pick an image from specified source (camera or gallery)
  // Compresses image for performance (quality 85%, max dimensions)
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85, // Balance quality and file size
        maxWidth: 1920, // Limit width for memory efficiency
        maxHeight: 1080, // Limit height for memory efficiency
      );

      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path); // Update reactive image
        recognizedText.value = ''; // Reset previous recognition
        await recognizeText(pickedImage.value!); // Trigger OCR
      }
    } catch (e) {
      // Show helpful tip instead of raw error
      _showPhotoTip('Error Picking Image', 'Ensure camera or gallery permissions are granted, and try again. If the issue persists, restart the app.');
    }
  }

  // Helper to remove leading zeros from numeric strings, preserving decimals
  // Ensures clean display (e.g., '00123.0' -> '123')
  String removeLeadingZeros(String number) {
    if (number.contains('.')) {
      final parts = number.split('.');
      final integerPart = int.parse(parts[0]).toString(); // Remove leading zeros in integer part
      final decimalPart = parts[1].replaceAll(RegExp(r'0+$'), ''); // Trim trailing zeros in decimal
      return decimalPart.isEmpty ? integerPart : '$integerPart.$decimalPart';
    } else {
      return int.parse(number).toString(); // Simple integer parsing for whole numbers
    }
  }

  // Converts Eastern Arabic-Indic digits to Western Arabic digits
  // Essential for numeric processing (e.g., '١٢٣' -> '123')
  String convertArabicDigitsToEnglish(String input) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (int i = 0; i < arabicDigits.length; i++) {
      input = input.replaceAll(arabicDigits[i], i.toString());
    }
    return input;
  }

  // Normalizes detected units to standard format
  // Maps variations like 'كيلو وات ساعة' to 'kWh' for consistency
  String normalizeUnit(String unit) {
    unit = unit.toLowerCase().trim();
    if (unit.contains('كيلو') || unit.contains('kwh')) {
      return 'kWh';
    }
    return unit; // Return as-is if no match
  }

  // Core OCR processing method
  // Extracts text blocks, matches meter patterns, scores confidence, and selects best reading
  // Improved for separate digit detection: collects all digit blocks, sorts by position, and concatenates close ones
  Future<void> recognizeText(File image) async {

    isLoading.value = true; // Start loading state
    recognizedText.value = ''; // Reset display

    try {
      // Prepare input for ML Kit
      final inputImage = InputImage.fromFile(image);
      final RecognizedText result = await textRecognizer.processImage(inputImage); // Perform OCR

      // Decode image to get dimensions for relative positioning
      final Uint8List imageBytes = image.readAsBytesSync(); // Read once to avoid multiple I/O
      final imageData = await decodeImageFromList(imageBytes);
      final imageHeight = imageData.height.toDouble();
      final imageWidth = imageData.width.toDouble();

      List<MeterReading> digitBlocks = []; // Collect individual digit or short number blocks

      // Regex for any sequence of digits (1+), optional decimal; flexible for separate digits in meters
      final digitRegex = RegExp(r'[\d٠١٢٣٤٥٦٧٨٩]+(\.[\d٠١٢٣٤٥٦٧٨٩]{1,3})?');

      // Regex to detect specific meter models (e.g., GGIE, 82E) for confidence boost
      final meterModelRegex = RegExp(r'(GGIE|CG61E|82E|B2E|CG61|عداد كهرباء)', caseSensitive: false);

      // Iterate over detected text blocks
      for (final block in result.blocks) {
        final blockY = block.boundingBox.top; // Vertical position
        final blockX = block.boundingBox.left; // Horizontal position
        final fullBlockText = block.text.toLowerCase(); // For model detection

        // Criteria for potential meter digits: upper/middle area, reasonable height, contains digits
        if (blockY < imageHeight * 0.8 &&
            block.boundingBox.height > imageHeight * 0.02 && // Slightly lower threshold for smaller digits
            digitRegex.hasMatch(block.text)) { // Only blocks with digits

          String text = block.text;
          print("Raw OCR block at ($blockX, $blockY): $text"); // Enhanced debug with position

          String convertedText = convertArabicDigitsToEnglish(text);
          print("Converted text: $convertedText"); // Debug after conversion

          final matches = digitRegex.allMatches(convertedText); // Find digit patterns

          for (final match in matches) {
            final numberPart = match.group(0)!;
            // Clean number (keep only digits and dot)
            String cleanNumber = numberPart.replaceAll(RegExp(r'[^\d.]'), '');

            // Skip if no valid number
            if (cleanNumber.isEmpty || !RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(cleanNumber)) continue;

            // Calculate base confidence
            double confidence = 0.0;
            // Central horizontal and upper position boost
            confidence += (blockX - (imageWidth * 0.5)).abs() < (imageWidth * 0.3) ? 0.2 : 0;
            confidence += blockY < imageHeight * 0.5 ? 0.2 : 0.1;
            // Boost for longer sequences (but accept shorts for concatenation)
            confidence += (cleanNumber.length >= 2 ? 0.2 : 0.1);

            // Unit presence (if any non-digit after, but rare for digit blocks)
            // Model detection boost
            if (meterModelRegex.hasMatch(fullBlockText)) {
              confidence += 0.3;
              print("Meter model detected near digits: $fullBlockText - Boosting confidence");
            }

            // Decimal validation
            if (cleanNumber.contains('.')) {
              final parts = cleanNumber.split('.');
              if (parts[1].length > 3 || parts[1].length == 0) {
                confidence -= 0.1;
              } else {
                confidence += 0.05;
              }
            }

            // Clamp and store with position for sorting
            confidence = confidence.clamp(0.0, 1.0);
            digitBlocks.add(MeterReading(
              value: cleanNumber,
              unit: null, // Units handled separately if needed
              confidence: confidence,
              position: block.boundingBox,
              left: blockX, // For horizontal sorting
            ));
          }
        }
      }

      print("Total digit blocks found: ${digitBlocks.length}"); // Debug count

      // Sort digit blocks by left position (x-coordinate) for left-to-right concatenation
      digitBlocks.sort((a, b) => a.left.compareTo(b.left));

      // Group and concatenate close blocks (e.g., separate digits in meter display)
      List<MeterReading> mergedReadings = [];
      if (digitBlocks.isNotEmpty) {
        List<MeterReading> currentGroup = [digitBlocks.first];
        double lastRight = digitBlocks.first.position.right;

        for (int i = 1; i < digitBlocks.length; i++) {
          final current = digitBlocks[i];
          final gap = current.left - lastRight; // Gap between previous right and current left

          // If gap is small (e.g., < 1.5x average digit width, approx imageWidth/50), concatenate
          if (gap < imageWidth * 0.02) { // Tunable threshold: ~2% of width for close digits
            currentGroup.add(current);
            lastRight = current.position.right;
          } else {
            // End group: concatenate values
            final concatenated = _concatenateGroup(currentGroup);
            if (concatenated.isNotEmpty) {
              // Average confidence for group
              final avgConfidence = currentGroup.map((b) => b.confidence).reduce((a, b) => a + b) / currentGroup.length;
              mergedReadings.add(MeterReading(
                value: concatenated,
                unit: null,
                confidence: avgConfidence,
                position: Rect.fromLTRB(
                  currentGroup.first.left,
                  currentGroup.first.position.top,
                  currentGroup.last.position.right,
                  currentGroup.last.position.bottom,
                ),
                left: currentGroup.first.left,
              ));
            }
            // Start new group
            currentGroup = [current];
            lastRight = current.position.right;
          }
        }
        // Handle last group
        final concatenated = _concatenateGroup(currentGroup);
        if (concatenated.isNotEmpty) {
          final avgConfidence = currentGroup.map((b) => b.confidence).reduce((a, b) => a + b) / currentGroup.length;
          mergedReadings.add(MeterReading(
            value: concatenated,
            unit: null,
            confidence: avgConfidence,
            position: Rect.fromLTRB(
              currentGroup.first.left,
              currentGroup.first.position.top,
              currentGroup.last.position.right,
              currentGroup.last.position.bottom,
            ),
            left: currentGroup.first.left,
          ));
        }
      }

      // Filter merged readings: only those with 4+ digits (typical meter length)
      final validReadings = mergedReadings.where((r) => r.value.length >= 4).toList();

      print("Merged valid readings: ${validReadings.map((r) => '${r.value} (conf: ${r.confidence})').toList()}"); // Debug merged

      // Select and display best reading
      if (validReadings.isNotEmpty) {
        validReadings.sort((a, b) => b.confidence.compareTo(a.confidence)); // Global sort by confidence
        final bestReading = validReadings.first;
        final cleanedValue = removeLeadingZeros(bestReading.value);
        final displayUnit = bestReading.unit ?? 'kWh'; // Default unit

        recognizedText.value = '$cleanedValue $displayUnit';
        finalText.value = '$cleanedValue $displayUnit';
        textController.text = cleanedValue; // Populate text field

      } else {
        // No match: Show helpful tips based on possible reasons
        _showPhotoTip(
          'No Valid Reading Found',
          'Possible reason: The image is unclear due to poor lighting, angled shot, or the meter being too far. \n\nTips for correct photography:\n• Shoot in strong, natural light.\n• Keep the camera parallel to the meter (no angles).\n• Focus on the digital display and fill the frame with it.\n• Try again with a closer, clearer image!',
          duration: const Duration(seconds: 10),
        );
      }
    } catch (e) {
      // Error handling: Show tip instead of raw error
      _showPhotoTip(
        'Error Processing Image',
        'Reason: Technical issue in text recognition. Ensure the image is clear and not blurry, and try again. If it continues, restart the app. \n\nTips: Shoot in high clarity, avoid shadows or reflections.',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Helper to show user-friendly photo tips in snackbar (no raw errors)
  void _showPhotoTip(String title, String message, {Duration? duration}) {
    recognizedText.value = 'No valid meter reading found';
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }

  // Helper to concatenate values in a group (left-to-right, preserve decimals if any)
  String _concatenateGroup(List<MeterReading> group) {
    if (group.isEmpty) return '';
    // Sort group by left position (already sorted, but ensure)
    group.sort((a, b) => a.left.compareTo(b.left));
    // Concatenate, but if any has decimal, place it at the end or handle carefully (simple: join as strings)
    String result = '';
    bool hasDecimal = false;
    for (final block in group) {
      if (block.value.contains('.')) {
        hasDecimal = true;
        // For simplicity, append full; in practice, meters rarely have decimals per digit
        result += block.value;
      } else {
        result += block.value;
      }
    }
    // If multiple decimals, this might error; for meters, assume at most one
    return result;
  }

  // Starts voice recognition session
  // Initializes speech service if needed, listens in Arabic (Egyptian dialect)
  Future<void> recognizeVoice({bool append = false}) async {

    bool hasInternet = await connectivityService.connected();

    if (!hasInternet) {
      Get.snackbar(
        'No Internet Connection',
        'Please connect to the internet before using Voice Recognition.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return;
    }



    try {
      // Initialize speech with status/error callbacks
      bool available = await speech.initialize(
        onStatus: (status) {
          print("Speech status: $status"); // Debug status changes
          if (status == 'done' || status == 'notListening') {
            isListening.value = false; // Update UI on stop
          }
        },
        onError: (error) {
          print("Speech error: ${error.errorMsg} (permanent: ${error.permanent})"); // Debug full error
          isListening.value = false;
          String tip = _getSpeechErrorTip(error); // Get specific tip based on error
          _showVoiceTip('Speech Recognition Error: ${error.errorMsg}', tip);
        },
      );

      if (!available) {
        _showVoiceTip('Speech Not Available', 'This device does not support speech recognition. Use photo or manual typing instead. Common on emulators—try a physical device.');
        return;
      }

      const String localeId = 'ar-EG'; // Arabic Egypt for local dialect support
      isListening.value = true; // Start listening UI
      recognizedVoiceText.value = append ? recognizedVoiceText.value : ''; // Preserve or reset

      // Listen with dictation mode for continuous input
      await speech.listen(
        localeId: localeId,
        listenMode: stt.ListenMode.dictation,
        partialResults: true, // Real-time updates
        onResult: (result) {
          recognizedVoiceText.value = cleanText(result.recognizedWords); // Clean and update

          if (result.finalResult) { // Process final result
            final double number = _parseInput(recognizedVoiceText.value);
            final displayValue = _formatNumber(number);
            recognizedText.value = '$displayValue kWh';
            finalText.value = '$displayValue kWh';

            // Update text field (append or replace)
            if (append) {
              textController.text = (textController.text + ' ' + result.recognizedWords).trim();
            } else {
              textController.text = result.recognizedWords;
            }
          }
        },
      );
    } catch (e) {
      print("Unexpected speech error: $e"); // Debug
      isListening.value = false;
      _showVoiceTip('Unexpected Voice Error', 'An unexpected error occurred. Check permissions, restart the app, or try manual input. Details: $e');
    }
  }

  // Helper to get specific tip based on speech error type
  String _getSpeechErrorTip(stt.SpeechRecognitionError error) {
    switch (error.errorMsg.toLowerCase()) {
      case 'no_match':
        return 'No speech detected. Speak louder or closer to the mic. Try in a quiet environment.';
      case 'network_error':
      case 'network_timeout':
        return 'Network issue. Check your internet connection—speech recognition requires online access on some devices.';
      case 'audio':
        return 'Audio input problem. Ensure microphone permissions are granted and no other apps are using the mic.';
      case 'permission_denied':
        return 'Microphone permission denied. Go to app settings and grant microphone access.';
      case 'not_available':
        return 'Speech service unavailable. Install/update Google Speech Services (Android) or try a different device.';
      case 'permanent':
        return 'Permanent error. Restart the app or device. If persists, speech may not be supported here.';
      default:
        return 'Speech recognition failed. Speak clearly in Arabic. Common fixes: Check permissions, quiet room, or slower speech.';
    }
  }

  // Helper to show user-friendly voice tips in snackbar
  void _showVoiceTip(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 5), // Slightly longer for tips
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Cleans input text for processing: keeps Arabic letters, digits, spaces, decimals; removes punctuation
  String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\u0621-\u064A0-9\s.]'), ' ') // Retain Arabic, digits, spaces, dots
        .replaceAll('،', ' ') // Replace Arabic comma
        .replaceAll('؟', '') // Remove Arabic question mark
        .trim(); // Remove leading/trailing whitespace
  }

  // Parses input to double: tries direct numeric parse first, falls back to Arabic word-to-number
  double _parseInput(String input) {
    // Extract numeric string for direct parsing
    String numericStr = input.replaceAll(RegExp(r'[^\d.]'), '');
    double? parsed = double.tryParse(numericStr);
    if (parsed != null) {
      return parsed;
    }
    // Fallback to word-based extraction for spoken numbers
    return extractArabicNumber(input);
  }

  // Formats double to string: integer if whole, else fixed with trimmed trailing zeros
  String _formatNumber(double number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString(); // Clean integer
    } else {
      return number.toStringAsFixed(3) // Up to 3 decimals
          .replaceAll(RegExp(r'0+$'), '') // Trim trailing zeros
          .replaceAll(RegExp(r'\.$'), ''); // Remove trailing dot
    }
  }

  // Processes input from any source (text, voice, OCR) and extracts final numeric value
  void processInput() {
    String input = '';
    if (textController.text.isNotEmpty) {
      input = cleanText(textController.text);
    } else if (recognizedVoiceText.value.isNotEmpty) {
      input = cleanText(recognizedVoiceText.value);
    } else if (recognizedText.value.isNotEmpty) {
      // Strip units from OCR result
      input = recognizedText.value.replaceAll(RegExp(r'\s*(kWh|kW|كيلو وات ساعة|وات ساعة|ساعة|kwh|kw|وات)'), '').trim();
    } else {
      // No input error
      Get.snackbar(
        'Error',
        'Please provide input via typing, voice, or image. Try taking a photo for automatic reading!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (input.isNotEmpty) {
      final double number = _parseInput(input);
      final displayValue = _formatNumber(number);
      finalText.value = '$displayValue kWh'; // Default unit

      // Reset states
      clearImage();
      textController.clear();
      recognizedVoiceText.value = '';

      // Success for manual input
      Get.snackbar(
        'Done!',
        'Reading saved: $displayValue kWh',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Clears picked image and resets OCR-related states
  void clearImage() {
    pickedImage.value = null;
    recognizedText.value = '';
  }
}

// Standalone function to extract numeric value from Arabic text (formal and colloquial words)
// Supports numbers up to hundreds; returns double for decimal compatibility
// Parses words sequentially, handling multipliers like 'مية' (100)
double extractArabicNumber(String text) {
  text = text.replaceAll("و", " ").trim(); // Normalize 'and' connector to space

  // Mapping of Arabic number words (formal + colloquial Egyptian variants)
  final Map<String, int> numbers = {
    'صفر': 0,
    'واحد': 1, 'واحدة': 1,
    'اتنين': 2, 'اثنين': 2,
    'تلاتة': 3, 'ثلاثة': 3,
    'أربعة': 4, 'اربعة': 4,
    'خمسة': 5,
    'ستة': 6,
    'سبعة': 7,
    'تمانية': 8, 'ثمانية': 8,
    'تسعة': 9,
    'عشرة': 10,
    'حداشر': 11, 'احد عشر': 11,
    'اتناشر': 12, 'اثنا عشر': 12,
    'تلتاشر': 13, 'ثلاثة عشر': 13,
    'اربعتاشر': 14, 'أربعة عشر': 14,
    'خمستاشر': 15, 'خمسة عشر': 15,
    'ستاشر': 16, 'ستة عشر': 16,
    'سبعتاشر': 17, 'سبعة عشر': 17,
    'تمنتاشر': 18, 'ثمانية عشر': 18,
    'تسعتاشر': 19, 'تسعة عشر': 19,
    'عشرين': 20,
    'تلاتين': 30, 'ثلاثين': 30,
    'اربعين': 40, 'أربعين': 40,
    'خمسين': 50,
    'ستين': 60,
    'سبعين': 70,
    'تمانين': 80, 'ثمانين': 80,
    'تسعين': 90,
    'مية': 100, 'مائة': 100,
  };

  double total = 0.0;
  double current = 0.0; // Accumulator for current number

  final words = text.split(' '); // Split into words

  for (var word in words) {
    if (numbers.containsKey(word)) {
      int value = numbers[word]!;
      if (value == 100) {
        // Multiply current or start new hundred
        current = (current == 0 ? 1 : current) * 100;
      } else if (value >= 10 && value % 10 == 0 && current != 0) {
        // Tens place addition (e.g., 'عشرين' after units)
        current += value;
      } else {
        // Simple addition for units/teens
        current += value;
      }
    }
  }

  total += current; // Add to total (supports simple phrases; extend for complex if needed)
  return total;
}