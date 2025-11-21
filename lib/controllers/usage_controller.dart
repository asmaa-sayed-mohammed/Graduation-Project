import 'package:get/get.dart';

class UsageController extends GetxController {
  var currentUsage = 320.obs;
  var currentPrice = 230.obs;

  // دمي داتا لـ 12 شهر
  List<double> usage12Months = [
    120, 160, 110, 140, 190, 175, 150, 200, 210, 195, 160, 140
  ];

  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
}
