import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  RxString latestUsageDifference = "0.0".obs; // الفرق بين آخر قراءتين
  RxDouble currentPrice = 0.0.obs; // آخر سعر فعلي
  RxList<double> price12Months = List<double>.filled(12, 0.0).obs;

  RxDouble manualUsage = 0.0.obs;
  RxDouble manualPrice = 0.0.obs;

  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchLatestTwoReadings(); // لحساب الفرق بين آخر قراءتين
    fetchLatestPrice(); // لجلب آخر سعر فعلي
    fetchMonthlyTotals(); // مجموع الأسعار لكل شهر
  }

  // جلب آخر قراءتين وحساب الفرق
  Future<void> fetchLatestTwoReadings() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      latestUsageDifference.value = "0.0";
      return;
    }

    try {
      final response = await supabase
          .from('usage_record')
          .select('reading, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(2);

      if (response != null && response is List && response.isNotEmpty) {
        double latest = (response[0]['reading'] as num).toDouble();
        double previous = response.length > 1
            ? (response[1]['reading'] as num).toDouble()
            : 0.0;

        double difference = latest - previous;
        latestUsageDifference.value = difference.toStringAsFixed(3);
      } else {
        latestUsageDifference.value = "0.0";
      }
    } catch (e) {
      print('Error fetching latest two readings: $e');
      latestUsageDifference.value = "0.0";
    }
  }

  // جلب آخر سعر فعلي
  Future<void> fetchLatestPrice() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      currentPrice.value = 0.0;
      return;
    }

    try {
      final response = await supabase
          .from('usage_record')
          .select('price')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response != null && response is List && response.isNotEmpty) {
        currentPrice.value = (response[0]['price'] as num).toDouble();
      } else {
        currentPrice.value = 0.0;
      }
    } catch (e) {
      print('Error fetching latest price: $e');
      currentPrice.value = 0.0;
    }
  }

  // جلب مجموع الأسعار لكل شهر (آخر 12 شهر)
  Future<void> fetchMonthlyTotals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('usage_record')
          .select('price, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      if (response != null && response is List && response.isNotEmpty) {
        Map<int, double> monthlyTotals = {};

        for (var record in response) {
          DateTime date = DateTime.parse(record['created_at']);
          double price = (record['price'] as num).toDouble();
          int monthIndex = date.month - 1;

          if (!monthlyTotals.containsKey(monthIndex)) {
            monthlyTotals[monthIndex] = 0.0;
          }
          monthlyTotals[monthIndex] = monthlyTotals[monthIndex]! + price;
        }

        for (int i = 0; i < 12; i++) {
          price12Months[i] = monthlyTotals[i] ?? 0.0;
        }
      } else {
        for (int i = 0; i < 12; i++) {
          price12Months[i] = 0.0;
        }
      }
    } catch (e) {
      print('Error fetching monthly totals: $e');
    }
  }

  double maxPriceValue() {
    if (price12Months.isEmpty) return 50;
    double max = price12Months.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 50 : max;
  }

  double priceStep() {
    double step = (maxPriceValue() / 5).ceilToDouble();
    return step == 0 ? 1 : step;
  }

  // ========================== حساب الشريحة ==========================
  String getCurrentTier() {
  double consumption = manualUsage.value > 0
      ? manualUsage.value
      : double.tryParse(latestUsageDifference.value) ?? 0.0;

  if (consumption <= 50) return 'الأولى';
  if (consumption <= 100) return 'الثانية';
  if (consumption <= 200) return 'الثالثة';
  if (consumption <= 350) return 'الرابعة';
  if (consumption <= 650) return 'الخامسة';
  if (consumption <= 1000) return 'السادسة';
  return 'السابعة';
}


}
