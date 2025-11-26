import 'package:get/get.dart';

class HomeController extends GetxController {
  // current usage / cost
  RxDouble currentUsage = 230.0.obs;
  RxDouble currentPrice = 0.0.obs;

  // months labels
  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  // dummy monthly usage (KWh)
  List<double> usage12Months = [
    120, 150, 190, 210, 260, 300,
    280, 240, 210, 180, 160, 140
  ];

  // computed monthly prices (EGP)
  List<double> price12Months = [];

  @override
  void onInit() {
    super.onInit();
    calculateAllPrices();
  }

  // ==============================
  // COST CALC BY TIERS
  // ==============================
  double calculateCost(double kwh) {
    double cost = 0;

    if (kwh <= 50) {
      cost = kwh * 0.68;
    } else if (kwh <= 100) {
      cost = (50 * 0.68) + ((kwh - 50) * 0.78);
    } else if (kwh <= 200) {
      cost = (50 * 0.68) + (50 * 0.78) + ((kwh - 100) * 0.95);
    } else if (kwh <= 350) {
      cost = (50 * 0.68) + (50 * 0.78) + (100 * 0.95) + ((kwh - 200) * 1.55);
    } else if (kwh <= 650) {
      cost = (50 * 0.68) + (50 * 0.78) + (100 * 0.95) + (150 * 1.55) + ((kwh - 350) * 1.95);
    } else if (kwh <= 1000) {
      cost = (50 * 0.68) + (50 * 0.78) + (100 * 0.95) + (150 * 1.55) + (300 * 1.95) + ((kwh - 650) * 2.10);
    } else {
      cost = (50 * 0.68) + (50 * 0.78) + (100 * 0.95) + (150 * 1.55) + (300 * 1.95) +
          (350 * 2.10) + ((kwh - 1000) * 2.23);
    }

    return double.parse(cost.toStringAsFixed(2));
  }

  // calculate for all months
  void calculateAllPrices() {
    price12Months = usage12Months.map((u) => calculateCost(u)).toList();

    currentPrice.value = calculateCost(currentUsage.value);
  }

  // max value for bar chart
  double maxPriceValue() {
    double maxVal = price12Months.reduce((a, b) => a > b ? a : b);
    return maxVal + 50; // padding
  }

  // interval steps for Y axis
  double priceStep() {
    double maxVal = price12Months.reduce((a, b) => a > b ? a : b);
    return maxVal / 5;
  }
}
