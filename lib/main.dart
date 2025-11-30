// main.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/models/profile_model_hive.dart';
import 'package:graduation_project/services/notification/notification_permission.dart';
import 'package:graduation_project/services/notification/notification_service.dart';
import 'package:graduation_project/services/notification/workmanager_service.dart';
import 'package:graduation_project/view/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استيراد المتحكم المطلوب وإضافته (Get.put)
import 'controllers/electricity_controller.dart';

import 'models/history_model.dart';
import 'models/usage_report_adapter.dart';

// تعريف الـ Boxes العالمية
late Box<ProfileHive> profileBox;
late Box<bool> onboarding;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Supabase
  await Supabase.initialize(
    url: 'https://qtkxpsgmmcubmaogzjck.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0a3hwc2dtbWN1Ym1hb2d6amNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMzYzNDEsImV4cCI6MjA3NzYxMjM0MX0.7VoDnNK1a7cptEBbiugbpw0PQMLpSGuxspQWS6sfV3Q',
  );

  // 2. تهيئة الإشعارات و WorkManager
  final notificationService = NotificationService();
  await notificationService.initialize();
  await requestNotificationPermission();

  if (!kIsWeb && Platform.isAndroid) {
    final workManagerService = WorkManagerService();
    await workManagerService.initialize();
    workManagerService.registerPeriodicNotification();
  }

  // 3. تهيئة Hive
  await Hive.initFlutter();

  // تسجيل الـ Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UsageRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProfileHiveAdapter());
  }

  // فتح الصناديق
  await Hive.openBox<UsageRecord>('history');
  profileBox = await Hive.openBox<ProfileHive>('profileBox');
  onboarding = await Hive.openBox<bool>('onboarding');

  // فتح صندوق settings
  await Hive.openBox('settings');

  // حقن المتحكم في GetX
  Get.put(ElectricityController());

  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // SplashScreen هيتولى تحديد أول شاشة حسب حالة المستخدم
      home: const SplashScreen(),
    );
  }
}