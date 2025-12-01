// main_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/view/company_screen.dart';
import 'package:graduation_project/view/start_screen.dart';
import '../controllers/bottom_navbar_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/smart_recommendation_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/bottom_navbar.dart';
import '../view/homescreen.dart';
import '../view/reading_screen.dart';
import '../view/budget_screen.dart';
import '../view/appliance_screen.dart';
import '../view/tips_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final AppliancesController appliancesController =Get.put(AppliancesController());
  final NavigationController controller = Get.put(NavigationController());
  final BudgetController budgetController = Get.put(BudgetController());
  final SmartRecommendationController recommendationController = Get.put(SmartRecommendationController());

  final List<Widget> _screens = [
     StartScreen(),
    ReadingScreen(),
    BudgetScreen(),
    CompanyScreen(),
    TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: _screens[controller.currentIndex.value],
      bottomNavigationBar: const BottomNavBar(),
    ));
  }
}
