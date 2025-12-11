import 'package:get/get.dart';
import '../models/user_appliance_model.dart';
import '../models/appliance_model.dart';
import '../services/appliance_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppliancesController extends GetxController {
  final ApplianceService _service = ApplianceService();

  final RxList<UserAppliance> userAppliances = <UserAppliance>[].obs;
  final RxList<Appliance> appliances = <Appliance>[].obs;
  final RxBool isLoading = false.obs;

  late final String userId;

  @override
  void onReady() {
    super.onReady();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
      loadData();
    }
  }

  /// -----------------------
  /// Total monthly consumption
  /// -----------------------
  double getTotalMonthlyConsumption({String? priority}) {
    double total = 0.0;
    for (final ua in userAppliances) {
      if (priority != null && ua.priority != priority) continue;
      total += ua.effectiveWatt * ua.hoursPerDay * ua.quantity / 1000 * 30;
    }
    return total;
  }

  /// -----------------------
  /// Load all data
  /// -----------------------
  Future<void> loadData() async {
    isLoading.value = true;

    final all = await _service.getAllAppliances();
    appliances.assignAll(all);

    final userList = await _service.getUserAppliances(userId);
    userAppliances.assignAll(userList);

    isLoading.value = false;
  }

  /// -----------------------
  /// Add ready appliance (existing)
  /// -----------------------
  Future<void> addApplianceCustom(
      Appliance appliance, {
        required double hoursPerDay,
        required int quantity,
        required String priority,
      }) async {
    await _service.addUserAppliance(
      applianceId: appliance.id!,
      hoursPerDay: hoursPerDay,
      quantity: quantity,
      priority: priority,
    );
    await loadData();
  }

  /// -----------------------
  /// Add custom appliance
  /// -----------------------
  Future<void> addCustomAppliance({
    required String name,
    required String brand,
    required int watt,
    required double hoursPerDay,
    required int quantity,
    String priority = "not_important",
  }) async {
    await _service.addCustomAppliance(
      userId: userId,
      customName: name,
      customBrand: brand,
      customWatt: watt,
      hoursPerDay: hoursPerDay,
      quantity: quantity,
      priority: priority,
    );
    await loadData();
  }

  /// -----------------------
  /// Update appliance (ready or custom)
  /// -----------------------
  Future<void> updateUserAppliance(UserAppliance ua) async {
    if (ua.id == null) return;
    isLoading.value = true;
    await _service.updateUserAppliance(
      ua.id!,
      hoursPerDay: ua.hoursPerDay,
      quantity: ua.quantity,
      priority: ua.priority ?? "not_important",
      customName: ua.customName ?? "",
      customBrand: ua.customBrand ?? "",
      customWatt: ua.customWatt ?? 0,
    );

    final index = userAppliances.indexWhere((e) => e.id == ua.id);
    if (index != -1) {
      userAppliances[index] = ua;
    }
  }

  /// -----------------------
  /// Delete appliance (ready or custom)
  /// -----------------------
  Future<void> deleteUserAppliance(UserAppliance ua) async {
    if (ua.id == null) return;
    await _service.deleteUserAppliance(ua.id!);
    userAppliances.removeWhere((e) => e.id == ua.id);
  }
}