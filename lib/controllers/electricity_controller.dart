// lib/controller/electricity_controller.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart'; // 💡 استبدال ChangeNotifier بـ GetX
import 'package:graduation_project/models/company_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

// 💡 تم إصلاح خطأ الاستيراد: استخدام الاستيراد العادي (يجب التأكد من تعريف companiesData كمتغير عام في الملف)
import '../models/electricity_data.dart'; 

// 💡 وراثة المتحكم من GetxController
class ElectricityController extends GetxController {
  // --- تهيئة Supabase ---
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- حالة Controller باستخدام المتغيرات القابلة للملاحظة (Rx) ---
  final RxString input = ''.obs;
  final Rxn<String> companyName = Rxn<String>(); // Rxn<T> لمتغير nullable
  final RxBool loading = false.obs;
  final RxBool isArabicInput = false.obs;

  // 💡 حالة المستخدم والشركة المفضلة
  final Rxn<User> currentUser = Rxn<User>();
  final Rxn<String> preferredCompany = Rxn<String>(); 

  // 💡 Getter محسوب
  TextDirection get textDirection =>
      isArabicInput.value ? TextDirection.rtl : TextDirection.ltr;

  // 💡 onInit() تستخدم بدلاً من Constructor لإجراء التهيئة
  @override
  void onInit() {
    super.onInit();
    
    // الاستماع لحالة المصادقة في Supabase
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      loadPreferredCompany(); 
    });

    // تحميل أولي للشركة المفضلة
    currentUser.value = _supabase.auth.currentUser;
    loadPreferredCompany();
  }

  // دالة إظهار رسالة (تُنفذ الآن باستخدام Get.snackbar)
  void _showGetSnackBar(String msg) {
    Get.snackbar(
      '', // العنوان (نتركه فارغاً)
      msg, // الرسالة
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFCC00),
      colorText: Colors.black,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    );
  }

  // 1. دوال إدارة التخزين (Supabase و Local) -------------------------

  Future<void> loadPreferredCompany() async {
    final user = currentUser.value; 

    if (user != null) {
      // 1. محاولة الجلب من Supabase
      try {
        final response = await _supabase
            .from('user_profiles')
            .select('company_name')
            .eq('id', user.id)
            .single();

        preferredCompany.value = response['company_name'] as String?; 
        return; 
      } catch (error) {
        debugPrint('Supabase profile not found or error, falling back to local storage: $error');
      }
    }

    // 2. التحميل من التخزين المحلي (Hive)
    final settingsBox = Hive.box('settings');
    preferredCompany.value = settingsBox.get('saved_company') as String?;
  }

  Future<void> saveCompany(String companyName) async {
    // 1. الحفظ في التخزين المحلي (Hive) كـ Cache
    final settingsBox = Hive.box('settings');
    await settingsBox.put('saved_company', companyName);

    final user = currentUser.value;

    if (user != null) {
      // 2. الحفظ في Supabase (فقط إذا كان المستخدم مسجلاً دخوله)
      final Map<String, dynamic> dataToSave = {
        'id': user.id,
        'company_name': companyName,
      };

      try {
        await _supabase.from('user_profiles').upsert(dataToSave);
        _showGetSnackBar('تم حفظ "${companyName}" في السحابة والتخزين المحلي بنجاح.'); 
      } catch (e) {
        debugPrint('Error saving to Supabase: $e');
        _showGetSnackBar('فشل في حفظ الشركة في السحابة. تم حفظها محلياً فقط.'); 
      }
    } else {
       _showGetSnackBar('تم حفظ الشركة "${companyName}" محلياً. يرجى تسجيل الدخول للحفظ في السحابة.'); 
    }

    preferredCompany.value = companyName; // تحديث قيمة Rx
  }

  // 2. دوال معالجة النص والبحث ----------------------------------------

  // دالة لتطبيع النص العربي (Normalization)
  String _normalizeArabicText(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll(RegExp(r'[يى]'), 'ي')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll(RegExp(r'ة'), 'ه')
        .replaceAll(RegExp(r'[\u064b-\u0652]'), '')
        .toLowerCase()
        .trim();
  }

  // دالة لتحديث إدخال المستخدم وتحديد اللغة
  void updateInput(String text) {
    input.value = text.trim(); // تحديث قيمة Rx
    isArabicInput.value = _detectArabic(input.value); // تحديث قيمة Rx
  }

  // دالة لاكتشاف وجود أحرف عربية
  bool _detectArabic(String text) {
    if (text.isEmpty) {
      return isArabicInput.value; 
    }
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  Future<void> findCompany() async {
    if (input.value.isEmpty) {
      companyName.value = null; // تحديث قيمة Rx
      _showGetSnackBar(isArabicInput.value
          ? 'من فضلك أدخل اسم المنطقة أو المحافظة'
          : 'Please enter your area or governorate name');
      return;
    }

    // تطبيق التطبيع على إدخال المستخدم
    String normalizedInput = _normalizeArabicText(input.value);

    String? company;
    // 💡 استخدام companiesData مباشرة
    for (var c in companiesData) { 
      final searchList = [
        ...(c['governorates'] as List<String>? ?? []),
        ...(c['areas'] as List<String>? ?? [])
      ];

      for (var item in searchList) {
        // تطبيق التطبيع على بيانات الشركة قبل المقارنة
        String normalizedItem = _normalizeArabicText(item.toString());

        if (normalizedItem.contains(normalizedInput) ||
            normalizedInput.contains(normalizedItem)) {
          // معالجة حالة الجيزة الخاصة
          if (c['governorates'] != null &&
              (c['governorates'] as List).contains('الجيزة') &&
              normalizedInput.contains('giza')) {
            company = 'South Giza Electricity Company';
          } else {
            company = isArabicInput.value ? c['name_ar'] : c['name_en'];
          }
          break;
        }
      }
      if (company != null) break;
    }

    companyName.value = company ?? // تحديث قيمة Rx
        (isArabicInput.value
            ? 'لم يتم العثور على شركة لهذه المنطقة'
            : 'No company found for this area');

    // استدعاء دالة الحفظ الموحدة (Supabase + Local)
    if (company != null && !companyName.value!.contains('No company found')) {
      // 💡 يتم الحفظ تلقائياً بعد البحث الناجح
      await saveCompany(company);
    }
  }
  
  // 💡 دالة جديدة: لحفظ الشركة الحالية بناءً على طلب المستخدم (زر الحفظ)
  Future<void> saveCurrentCompany() async {
    final currentCompany = companyName.value;

    // التحقق من وجود شركة صالحة للحفظ
    if (currentCompany == null || 
        currentCompany.contains('لم يتم العثور') ||
        currentCompany.contains('No company found')) {
      _showGetSnackBar(isArabicInput.value
          ? 'لا يمكن حفظ شركة غير محددة.'
          : 'Cannot save an undefined company.');
      return;
    }
    
    // استدعاء دالة الحفظ الموحدة (التي تدير Hive و Supabase)
    await saveCompany(currentCompany); 
  }

  Future<void> getLocationAndFindCompany() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showGetSnackBar(isArabicInput.value
          ? 'من فضلك فعّل خدمة الموقع GPS'
          : 'Please enable location service');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _showGetSnackBar(isArabicInput.value
          ? 'تم رفض إذن الوصول للموقع، يرجى تفعيله من الإعدادات.'
          : 'Location permission denied, please enable it in settings.');
      return;
    }

    loading.value = true; // تحديث قيمة Rx
    
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 100,
    );

    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        // التركيز على المحافظة والمدينة لتبسيط البحث عن الشركة
        String area = placemarks.first.administrativeArea ?? ''; // المحافظة
        String city = placemarks.first.locality ?? ''; // المدينة/المنطقة الإدارية

        String placeName = '';

        // بناء اسم المكان بتركيز على المحافظة والمدينة
        if (city.isNotEmpty && area.isNotEmpty && city != area) {
          placeName = '$city, $area';
        } else if (area.isNotEmpty) {
          placeName = area;
        } else if (city.isNotEmpty) {
          placeName = city;
        }

        if (placeName.isEmpty) {
          // رسالة في حال فشل تحديد المنطقة الإدارية
          input.value = isArabicInput.value
              ? 'تعذر تحديد المحافظة/المنطقة'
              : 'Could not determine area/governorate';
        } else {
          input.value = placeName;
        }

        isArabicInput.value = _detectArabic(input.value); 

        await findCompany();
      } else {
        _showGetSnackBar(isArabicInput.value
            ? 'تعذر تحديد اسم المنطقة من الموقع'
            : 'Could not determine area name from location');
      }
    } on TimeoutException {
      _showGetSnackBar(isArabicInput.value
          ? 'انتهى الوقت المخصص للحصول على الموقع، جرب مرة أخرى.'
          : 'Location timeout, please try again.');
    } catch (e) {
      debugPrint('Location or Geocoding failed: $e');
      _showGetSnackBar(isArabicInput.value
          ? 'فشل في الحصول على الموقع: $e'
          : 'Failed to get location: $e');
    }

    loading.value = false; // تحديث قيمة Rx
  }

  Future<void> openMap() async {
    if (companyName.value == null ||
        companyName.value!.contains('لم يتم العثور') ||
        companyName.value!.contains('No company found')) {
      _showGetSnackBar(isArabicInput.value
          ? 'ابحث عن الشركة أولاً أو تأكد من وجودها'
          : 'Search for a company first or ensure it exists');
      return;
    }

    final companyKey = companyName.value == 'South Giza Electricity Company'
        ? 'South Cairo Electricity Distribution Company'
        : companyName.value;

    // 💡 استخدام companiesData مباشرة
    final company = companiesData.firstWhere(
        (c) => c['name_ar'] == companyKey || c['name_en'] == companyKey,
        orElse: () => <String, dynamic>{});

    if (company.isEmpty || company['latitude'] == null) {
      _showGetSnackBar(isArabicInput.value
          ? 'لا يوجد موقع محدد لهذه الشركة'
          : 'No location found for this company');
      return;
    }

    // تأمين الوصول إلى اللات واللونغ
    final lat = company['latitude'] as double?;
    final lng = company['longitude'] as double?;

    if (lat == null || lng == null) {
      _showGetSnackBar(isArabicInput.value
          ? 'خطأ في بيانات الموقع'
          : 'Location data error');
      return;
    }

    final urlString = 'geo:$lat,$lng?q=${Uri.encodeComponent(companyKey!)}';
    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showGetSnackBar(isArabicInput.value
          ? 'تعذر فتح تطبيق الخرائط'
          : 'Could not open Map application');
    }
  }
}