import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/profile_services.dart';
import '../../services/profile_hive_services.dart';
import '../../models/profile_model_supabase.dart';
import '../../models/profile_model_hive.dart';
import '../../models/signup_model.dart';
import '../services/connectivity_service.dart';

class SignUpController extends GetxController {
  final AuthService auth = AuthService();
  final ProfileService _profileService = ProfileService();
  final ProfileHiveService _hiveService;

  SignUpController(this._hiveService);
  RxBool isAccountCreated = false.obs;
  RxBool isLoading = false.obs;
  final connectivityService = ConnectivityService();
  late bool hasInternet;

  String? userId;
  SignUpModel model = SignUpModel(
    email: "",
    password: "",
    name: "",
    address: "",
    company: "",
  );

  Future<void> registerAccount() async {
    try {
      hasInternet = await connectivityService.connected();
      if(!hasInternet){
        Get.snackbar(
          'لا يوجد اتصال بالإنترنت',
          'من فضلك اتصل بالإنترنت لتسجيل الدخول',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }else{
        isLoading.value = true;

        final user = await auth.register(model.email, model.password);

        if (user != null) {
          userId = user.id;

          await Get.defaultDialog(
            title: "تأكيد الإيميل",
            middleText: "يرجى التحقق من بريدك الإلكتروني لتأكيد الحساب قبل المتابعة.",
            barrierDismissible: false,
            textConfirm: "حسنا",
            onConfirm: () {
              Get.back();
            },
          );

          isAccountCreated.value = true;
        } else {
          Get.snackbar("خطأ", "فشل إنشاء الحساب");
        }
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء إنشاء الحساب: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    try {
      hasInternet = await connectivityService.connected();
      if(!hasInternet){
        Get.snackbar(
          'لا يوجد اتصال بالإنترنت',
          'من فضلك اتصل بالإنترنت لحفظ بياناتك',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }else{
        isLoading.value = true;

        if (userId == null) {
          Get.snackbar("خطأ", "لم يتم إنشاء الحساب بعد");
          return;
        }

        // عرض معلومات الحفظ
        Get.snackbar("بدء الحفظ", "جاري حفظ البيانات...", duration: 2.seconds);

        final hiveProfile = ProfileHive(
          id: userId!,
          name: model.name,
          createdAt: DateTime.now(),
          company_Name: model.company,
          address: model.address,
        );

        // حفظ في Hive
        await _hiveService.addProfile(hiveProfile);
        Get.snackbar("نجاح", "تم حفظ البيانات في Hive", duration: 2.seconds);

        // حفظ في Supabase
        final profile = ProfileModel(
          id: userId!,
          name: model.name,
          address: model.address,
          company_Name: model.company,
          created_at: DateTime.now(),
        );

        final supabaseSuccess = await _profileService.createProfile(profile);

        if (supabaseSuccess) {
          Get.snackbar("نجاح", "تم حفظ البيانات في السحابة", duration: 2.seconds);
        } else {
          Get.snackbar("تحذير", "تم الحفظ محلياً فقط", duration: 3.seconds);
        }

        // تحقق نهائي من البيانات
        final allProfiles = _hiveService.getProfiles();
        Get.snackbar("التحقق", "عدد البروفايلات في Hive: ${allProfiles.length}", duration: 3.seconds);

        Get.offAllNamed("/home");
      }

    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ: ${e.toString()}", duration: 5.seconds);
    } finally {
      isLoading.value = false;
    }
  }

  // دالة للتسجيل الكامل
  Future<void> completeSignUp() async {
    await registerAccount();
  }
}