import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/models/user_appliance_model.dart';
import 'package:graduation_project/core/style/colors.dart';
import '../../core/widgets/page_header.dart'; // استدعاء الهيدر الجديد

class MyAppliancesScreen extends StatelessWidget {
  final AppliancesController controller = Get.find<AppliancesController>();

  MyAppliancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white2,
        body: Column(
          children: [
            // ===== الهيدر القابل لإعادة الاستخدام =====
            const PageHeader(title: 'أجهزتي'),
      
            // ===== محتوى الصفحة =====
            Expanded(child: _buildBody()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/select-appliances'); // Navigate to SelectAppliancesScreen
          },
          backgroundColor: AppColor.primary_color,
          foregroundColor: AppColor.black,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.userAppliances.isEmpty) return _buildEmptyState();

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.userAppliances.length,
        itemBuilder: (context, index) {
          final userAppliance = controller.userAppliances[index];
          return _buildApplianceItem(userAppliance);
        },
      );
    });
  }

  Widget _buildApplianceItem(UserAppliance userAppliance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColor.primary_color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.bolt,
            color: AppColor.primary_color,
          ),
        ),
        title: Text(
          userAppliance.appliance?.name ?? 'جهاز',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${userAppliance.brand} - ${userAppliance.model}',
              style: TextStyle(
                color: AppColor.gray,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${userAppliance.hoursPerDay} ساعة/يوم',
              style: TextStyle(
                color: AppColor.primary_color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editAppliance(userAppliance),
              icon: Icon(
                Icons.edit,
                color: AppColor.blue,
              ),
            ),
            IconButton(
              onPressed: () => _deleteAppliance(userAppliance),
              icon: Icon(
                Icons.delete,
                color: AppColor.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            color: AppColor.gray2,
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد أجهزة',
            style: TextStyle(
              color: AppColor.gray,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'اضغط على + لإضافة أجهزة',
            style: TextStyle(
              color: AppColor.gray2,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _editAppliance(UserAppliance userAppliance) {
    final hoursController = TextEditingController(text: userAppliance.hoursPerDay.toString());

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الجهاز'),
        content: TextFormField(
          controller: hoursController,
          decoration: const InputDecoration(
            labelText: 'ساعات الاستخدام اليومية',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              userAppliance.copyWith(
                hoursPerDay: double.tryParse(hoursController.text) ?? userAppliance.hoursPerDay,
              );
              await controller.updateUserAppliance(userAppliance);
              Get.back();
              Get.snackbar(
                'تم التعديل',
                'تم تعديل الجهاز بنجاح',
                backgroundColor: AppColor.green,
                colorText: AppColor.white,
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteAppliance(UserAppliance userAppliance) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الجهاز'),
        content: const Text('هل أنت متأكد من حذف هذا الجهاز؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteUserAppliance(userAppliance.id);
              controller.userAppliances.remove(userAppliance);
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف الجهاز بنجاح',
                backgroundColor: AppColor.green,
                colorText: AppColor.white,
              );
            },
            child: Text(
              'حذف',
              style: TextStyle(color: AppColor.red),
            ),
          ),
        ],
      ),
    );
  }
}
