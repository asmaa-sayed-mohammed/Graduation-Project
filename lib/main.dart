import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/models/profile_model_hive.dart';
import 'package:graduation_project/services/notification/notification_permission.dart';
import 'package:graduation_project/services/notification/notification_service.dart';
import 'package:graduation_project/services/notification/workmanager_service.dart';
import 'package:graduation_project/view/onBoarding_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import 'package:graduation_project/view/splash_screen.dart';
import 'package:graduation_project/view/tips_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/history_model.dart';
import 'models/usage_report_adapter.dart';

late Box<ProfileHive> profileBox;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://qtkxpsgmmcubmaogzjck.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0a3hwc2dtbWN1Ym1hb2d6amNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMzYzNDEsImV4cCI6MjA3NzYxMjM0MX0.7VoDnNK1a7cptEBbiugbpw0PQMLpSGuxspQWS6sfV3Q');

  final notificationService = NotificationService();
  await notificationService.initialize();
  await requestNotificationPermission();

  if (!kIsWeb && Platform.isAndroid) {
    final workManagerService = WorkManagerService();
    await workManagerService.initialize();
    workManagerService.registerPeriodicNotification();
  }

  await Hive.initFlutter();

  // تسجيل Adapter بتاع تسجيل  الاستخدام
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UsageRecordAdapter());

  }
  // تسجيل Adapter بتاع ال profile
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProfileHiveAdapter());
  }
  // فتح hive
  await Hive.openBox<UsageRecord>('history');
  profileBox = await Hive.openBox<ProfileHive>('profileBox');

  runApp(MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
