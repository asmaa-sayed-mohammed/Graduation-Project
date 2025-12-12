import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // تأثير bounce
    );

    // بدء الأنيميشن
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // اجعل كل شيء من اليمين لليسار
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.white2,
          body: Column(
            children: [
              PageHeader(
                title: "نصائح عامة",
                subtitle: "استهلاك أقل .. توفير أكبر ",
                leading: IconButton(icon:  const Icon(Icons.arrow_forward, color: Colors.black, size: 26,), onPressed: ()=>Get.back(),),
                // trailing: const Icon(Icons.ad, color: Colors.black, size: 28),
              ),
        
              const SizedBox(height: 10),
        
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildAnimatedTip(
                      icon: Icons.power_settings_new,
                      title: "افصل الأجهزة بعد الاستخدام",
                      content:
                      "بعض الأجهزة تستهلك كهرباء حتى وهي مغلقة. افصلها من الكهرباء بعد الاستخدام.",
                    ),
                    _buildAnimatedTip(
                      icon: Icons.ac_unit,
                      title: "اضبط التكييف على 25 درجة",
                      content:
                      "كل درجة أقل من 25 تزيد استهلاك الكهرباء بنسبة كبيرة.",
                    ),
                    _buildAnimatedTip(
                      icon: Icons.lightbulb,
                      title: "استخدم اللمبات الموفّرة LED",
                      content:
                      "استهلاكها أقل بنسبة 70% مقارنة باللمبات العادية.",
                    ),
                    _buildAnimatedTip(
                      icon: Icons.kitchen,
                      title: "نظّف جوانب الثلاجة",
                      content:
                      "اتّساخ الملفات الخلفية للثلاجة يزود استهلاك الكهرباء.",
                    ),
                    _buildAnimatedTip(
                      icon: Icons.water_drop,
                      title: "قلّل من استخدام السخان",
                      content:
                      "شغّله وقت الحاجة فقط، وسيبه على درجة حرارة متوسطة.",
                    ),
                    _buildAnimatedTip(
                      icon: Icons.timer,
                      title: "استخدم Timer للأجهزة",
                      content:
                      "لتحديد وقت تشغيل التكييف أو السخان وتقليل استهلاك الكهرباء.",
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

  // ---------------------------------------------------
  // بطاقة النصيحة مع تأثير الـ bounce
  // ---------------------------------------------------
  Widget _buildAnimatedTip({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.gray2,
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.primary_color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColor.primary_color),
            ),

            const SizedBox(width: 14),

            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(
                      color: AppColor.gray,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}