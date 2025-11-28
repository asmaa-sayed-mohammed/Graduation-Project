import 'package:get/get.dart';
import 'package:graduation_project/services/auth_service.dart';
import '../models/profile_model_hive.dart';
import '../services/profile_hive_services.dart';
import '../main.dart';

class ProfileController extends GetxController {
  final profile = Rx<ProfileHive?>(null);
  final _authService = AuthService();
  late String userId;

  late final ProfileHiveService _profileService;

  @override
  void onInit() {
    super.onInit();
    _profileService = ProfileHiveService(profileBox);
    loadProfile();
  }

  void loadProfile() {
    try {
      userId = _authService.getUserId().toString();
      final data = _profileService.getOneProfile(userId);

      if (data != null) {
        profile.value = data;
      } else {
        profile.value = null;
      }
    } catch (e) {
      print("❌ Error loading profile from Hive: $e");
      profile.value = null;
    }
  }
}
