import 'package:get/get.dart';
import 'package:graduation_project/models/profile_model_hive.dart';
import 'package:graduation_project/services/profile_services.dart';
import '../services/profile_hive_services.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../main.dart'; // عشان profileBox

class ProfileController extends GetxController {
  final profile = Rx<ProfileHive?>(null);
  final _authService = AuthService();
  late final ProfileHiveService _profileService;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _profileService = ProfileHiveService(profileBox);
    syncProfile(); // نسحب البيانات من Supabase ونخزنها في Hive + UI
  }

  // =========================
  // مزامنة البروفايل
  Future<void> syncProfile() async {
    try {
      final id = await _authService.getUserId();
      if (id == null) {
        print("⚠️ User ID is null");
        return;
      }

      // جلب البيانات من Supabase
      final profileSupabase = await ProfileService().getProfile(id);
      if (profileSupabase == null) {
        print("⚠️ No profile found on Supabase");
        return;
      }

      // تحويل لموديل Hive
      final profileHive = ProfileHive(
        id: profileSupabase.id!,
        name: profileSupabase.name!,
        createdAt: DateTime.now().toIso8601String(), // لازم تكون DateTime مش String
        address: profileSupabase.address,
        companyName: profileSupabase.company_Name, // الاسم مطابق للـ UI
      );

      // حفظ في Hive
      await _profileService.addProfile(profileHive);

      // تحديث الـ Rx عشان UI يتحدث مباشرة
      profile.value = profileHive;

      print("✅ Profile saved to Hive and UI updated");
    } catch (e) {
      print("❌ Error syncing profile: $e");
    }
  }

  // تحميل البروفايل من Hive لو موجود (اختياري)
  void loadProfileFromHive() {
    try {
      isLoading.value = true;
      final id = _authService.getUserId();
      if (id == null) return;
      final data = _profileService.getOneProfile(id.toString());
      profile.value = data;
    } catch (e) {
      print("❌ Error loading profile from Hive: $e");
      profile.value = null;
    }finally {
      isLoading.value = false;
    }
  }
}
