import 'package:get/get.dart';
import 'package:graduation_project/services/appliance_service.dart';
import 'package:graduation_project/models/energy_tip_model.dart';

class TipsController extends GetxController {
  final ApplianceService _applianceService = ApplianceService(); // بدون parameters

  final RxList<EnergyTip> staticTips = <EnergyTip>[].obs;
  final RxList<EnergyTip> customTips = <EnergyTip>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasUserAppliances = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      isLoading.value = true;

      final List<EnergyTip> static = await _applianceService.getStaticTips();
      staticTips.assignAll(static);

      final List<EnergyTip> custom = await _applianceService.getEnergyTipsForUserAppliances();
      customTips.assignAll(custom);

      hasUserAppliances.value = await _checkUserAppliances();

    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل النصائح: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkUserAppliances() async {
    try {
      final userAppliances = await _applianceService.getUserAppliances(_applianceService.getCurrentUserId());
      return userAppliances.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}