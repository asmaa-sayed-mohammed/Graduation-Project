import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LocalizationController extends GetxController {
  final Box settingsBox;
  LocalizationController(this.settingsBox);

  final String _localeKey = 'locale';

  Locale get locale {
    String? lang = settingsBox.get(_localeKey);
    return Locale(lang ?? 'ar'); // default "ar"
  }

  Future<void> setLocale(String langCode) async {
    await settingsBox.put(_localeKey, langCode);
    Get.updateLocale(Locale(langCode));
  }
}
