import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/tips_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/view/appliance_screen.dart';
import '../controllers/bottom_navbar_controller.dart';
import '../core/widgets/bottom_navbar.dart';
import '../models/energy_tip_model.dart';
import '../../core/widgets/page_header.dart'; // استدعاء الهيدر

class TipsScreen extends StatelessWidget {
  TipsScreen({super.key});

  final TipsController controller = Get.put(TipsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ===== الهيدر الثابت القابل لإعادة الاستخدام =====
            const PageHeader(
              title: 'نصائح التوفير الذكية',
              subtitle: 'استفد من خبراتنا لتوفير الطاقة',
            ),

            // ===== محتوى النصائح =====
            Expanded(child: _buildTipsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsContent() {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoadingState();

      return CustomScrollView(
        slivers: [
          _buildStaticTipsSection(),
          _buildCustomTipsSection(),
        ],
      );
    });
  }

  Widget _buildStaticTipsSection() {
    return Obx(() {
      final List<EnergyTip> staticTips = controller.staticTips;

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildSectionHeader(
              icon: Icons.lightbulb_outline,
              title: 'نصائح عامة للتوفير',
              subtitle: 'نصائح مفيدة تنطبق على جميع الأجهزة',
            ),
            const SizedBox(height: 16),
            if (staticTips.isEmpty)
              _buildEmptySection('لا توجد نصائح عامة متاحة')
            else
              ...staticTips.map((final EnergyTip tip) => _buildTipCard(tip, isCustom: false)),
          ]),
        ),
      );
    });
  }

  Widget _buildCustomTipsSection() {
    return Obx(() {
      final List<EnergyTip> customTips = controller.customTips;
      final bool hasUserAppliances = controller.hasUserAppliances.value;

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildSectionHeader(
              icon: Icons.person_outline,
              title: 'نصائح مخصصة لك',
              subtitle: hasUserAppliances
                  ? 'نصائح مخصصة بناءاً على أجهزتك'
                  : 'أضف أجهزتك للحصول على نصائح مخصصة',
            ),
            const SizedBox(height: 16),
            if (!hasUserAppliances) ...[
              _buildAddAppliancesButton(),
              const SizedBox(height: 16),
            ],
            if (hasUserAppliances && customTips.isEmpty)
              _buildEmptySection('لا توجد نصائح مخصصة لأجهزتك الحالية')
            else if (hasUserAppliances)
              ...customTips.map((final EnergyTip tip) => _buildTipCard(tip, isCustom: true)),
          ]),
        ),
      );
    });
  }

  Widget _buildSectionHeader({
    required final IconData icon,
    required final String title,
    required final String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary_color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColor.primary_color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColor.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Text(
            subtitle,
            style: TextStyle(color: AppColor.gray, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(final EnergyTip tip, {required final bool isCustom}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColor.white, AppColor.white2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(tip.priority),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(tip.priority),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCustom ? AppColor.primary_color : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCustom ? Icons.person : Icons.public,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCustom ? 'مخصصة' : 'عامة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                tip.description,
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (tip.applianceId != null && tip.applianceId! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primary_color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.devices,
                        size: 14,
                        color: AppColor.primary_color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مخصص لهذا الجهاز',
                        style: TextStyle(
                          color: AppColor.primary_color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.savings,
                      size: 14,
                      color: AppColor.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'توفير في استهلاك الطاقة',
                      style: TextStyle(
                        color: AppColor.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAppliancesButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary_color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary_color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle_outline, color: AppColor.primary_color, size: 40),
          const SizedBox(height: 12),
          Text(
            'أضف أجهزتك للحصول على نصائح مخصصة',
            style: TextStyle(
              color: AppColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Get.to(AppliancesScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_color,
              foregroundColor: AppColor.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              'إضافة أجهزتي',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(final String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.white2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gray2.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColor.gray, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColor.gray, fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري تحميل النصائح...',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(final int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(final int priority) {
    switch (priority) {
      case 1:
        return 'عالية الأهمية';
      case 2:
        return 'متوسطة الأهمية';
      case 3:
        return 'منخفضة الأهمية';
      default:
        return 'مهمة';
    }
  }
}
