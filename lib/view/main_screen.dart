import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/budget_and_user_appliances_screen.dart';
import 'package:graduation_project/view/company_screen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import 'package:graduation_project/view/recommendations_screen.dart';
import 'package:graduation_project/view/start_screen.dart';
import 'package:graduation_project/view/tips_screen.dart';
import '../controllers/bottom_navbar_controller.dart';
import '../core/widgets/bottom_navbar.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> pages = [
    StartScreen(),
    ReadingScreen(),
    BudgetAndAppliancesScreen(),
    CompanyScreen(),
    RecommendationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: navController.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: const BottomNavBar(),
    ));
  }
}
