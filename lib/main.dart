import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/onBoarding_screen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import 'package:graduation_project/view/splash_screen.dart';
import 'package:graduation_project/view/tips_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile_model_hive.dart';

late Box<ProfileHive> profileBox;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'https://qtkxpsgmmcubmaogzjck.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0a3hwc2dtbWN1Ym1hb2d6amNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMzYzNDEsImV4cCI6MjA3NzYxMjM0MX0.7VoDnNK1a7cptEBbiugbpw0PQMLpSGuxspQWS6sfV3Q');
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  profileBox = await Hive.openBox('profileHiveBox');
  Hive.registerAdapter(ProfileHiveAdapter());
  runApp( MyApp());
}





final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}