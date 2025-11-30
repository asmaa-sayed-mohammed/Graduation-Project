// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bottom_navbar_controller.dart';
import '../style/colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    return Obx(() => BottomNavigationBar(
      currentIndex: controller.currentIndex.value,
      onTap: (index) => controller.changePage(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'قراءة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money_outlined),
          activeIcon: Icon(Icons.attach_money),
          label: 'الميزانية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices_outlined),
          activeIcon: Icon(Icons.devices),
          label: 'الأجهزة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          activeIcon: Icon(Icons.lightbulb),
          label: 'النصائح',
        ),
      ],
      backgroundColor: AppColor.white,
      selectedItemColor: AppColor.primary_color,
      unselectedItemColor: AppColor.gray,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ));
  }
}
