import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/controllers/budget_controller.dart';
import 'package:graduation_project/controllers/smart_recommendation_controller.dart';
import 'package:graduation_project/controllers/start_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController()); // تسجيل HomeController عالمياً (lazy عشان ما يتحملش إلا لما يحتاج)
    Get.lazyPut(() => BudgetController());
    Get.lazyPut(() => AppliancesController());
    Get.lazyPut(() => SmartRecommendationController());
  }
}