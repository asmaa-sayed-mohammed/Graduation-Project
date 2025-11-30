// lib/view/electricity_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../controllers/electricity_controller.dart'; // مسار افتراضي، تأكد من صحته

// 💡 تعريف اللون الأصفر الموحد
const Color primaryYellowColor = Color(0xFFFFCC00);

// Custom Painter (تم نقله إلى هنا مؤقتاً، يمكن وضعه في ملف مساعد)
class YellowCurvedPainter extends CustomPainter {
 @override
void paint(Canvas canvas, Size size) {
final paint = Paint()
..color = primaryYellowColor 
..style = PaintingStyle.fill;

final path = Path();
path.lineTo(0, size.height * 0.4);
path.quadraticBezierTo(
 size.width * 0.5,
 size.height * 1.0,
 size.width,
 size.height * 0.4,
);
path.lineTo(size.width, 0);
path.close();

canvas.drawPath(path, paint);
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
return false;
}
}

// 💡 تحويل إلى GetView وربطه بالمتحكم
class ElectricityPage extends GetView<ElectricityController> {
const ElectricityPage({super.key});

 // الهيدر المخصص باللون الأصفر - (تم التعديل: أصبح يتلقى المتحكم كمعامل)
Widget _buildCurvedHeader(BuildContext context, ElectricityController ctrl) {
 return Container(
color: Colors.white,
child: Stack(
alignment: Alignment.topCenter,
children: [
CustomPaint(
 size: Size(MediaQuery.of(context).size.width, 240),
 painter: YellowCurvedPainter(),
),
Padding(
 padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
 child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
 // 💡 استخدام Obx للاستماع لتغير isArabicInput
Obx(() => Text(
ctrl.isArabicInput.value // 💡 استخدام ctrl بدلاً من controller
 ? 'شركة الكهرباء'
 : 'Electricity company',
style: const TextStyle(
color: Colors.black,
fontSize: 24,
fontWeight: FontWeight.bold),
)),],
),
),],
),
);
}

@override
Widget build(BuildContext context) {
 // 💡 Obx الرئيسية لتحديث الـ Directionality
return Obx(() { 
final isArabic = controller.isArabicInput.value;
final textDir = isArabic ? TextDirection.rtl : TextDirection.ltr;

return Directionality(
 textDirection: textDir,
 child: Scaffold(
 body: SingleChildScrollView(
child: Column(
children: [
 // 💡 تم التعديل: تمرير المتحكم controller إلى الدالة المساعدة
_buildCurvedHeader(context, controller), 
Padding(
padding: const EdgeInsets.symmetric(
 horizontal: 24.0, vertical: 30),
 child: Column(
children: [
 // حقل الإدخال
TextField(
 textAlign: isArabic ? TextAlign.right : TextAlign.left,
 style: const TextStyle(fontSize: 16),
decoration: InputDecoration(
hintText: isArabic
? 'أدخل اسم المنطقة أو المحافظة'
: 'faisal.giza',
 hintStyle: const TextStyle(color: Colors.grey),
 suffixIcon: IconButton(
icon: Icon(Icons.location_searching,
 color: Colors.black54,
 textDirection: textDir),
onPressed: controller.getLocationAndFindCompany,
),
 border: OutlineInputBorder(
borderRadius: BorderRadius.circular(30.0),
borderSide: BorderSide.none,
),
filled: true,
fillColor: Colors.grey.shade200,
contentPadding: const EdgeInsets.symmetric(
horizontal: 20, vertical: 15),
),
 // 💡 إرسال الإدخال إلى Controller
onChanged: controller.updateInput,
 // عرض القيمة الحالية من المتحكم يضمن بقاء حقل النص متزامناً
 controller: TextEditingController(text: controller.input.value)
..selection = TextSelection.fromPosition(
 TextPosition(offset: controller.input.value.length)),
),
const SizedBox(height: 30),
 // 1. زر البحث
ElevatedButton(
 style: ElevatedButton.styleFrom(
 backgroundColor: primaryYellowColor, 
 foregroundColor: Colors.black,
 shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30)),
padding: const EdgeInsets.symmetric(
 vertical: 18, horizontal: 80),
),
onPressed: controller.findCompany, 
child: Text(
isArabic ? 'ابحث عن الشركة' : 'Find the company',
style: const TextStyle(
fontSize: 16, fontWeight: FontWeight.bold),
),
),
const SizedBox(height: 40),
 // 💡 استخدام Obx هنا للتعامل مع حالات loading والنتيجة
Obx(() {
if (controller.loading.value) {
 return const Center(child: CircularProgressIndicator());
} 
                        // التحقق من وجود شركة صالحة لعرض النتيجة والأزرار
                        else if (controller.companyName.value != null) {
final companyFound = controller.companyName.value!;
                          final isCompanyValid = !companyFound.contains('لم يتم العثور') && 
                                                 !companyFound.contains('No company found');
                          
 // مربع النتيجة
return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(30),
 decoration: BoxDecoration(
color: primaryYellowColor.withOpacity(0.1),
borderRadius: BorderRadius.circular(15),
border: Border.all(
 color: primaryYellowColor, width: 2),
boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.05),
 spreadRadius: 1,
 blurRadius: 5,
 offset: const Offset(0, 3),),
],
 ),
child: Column(
 children: [
Text(
 companyFound, 
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
color: Colors.black),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 20),
 // 💡 وضع الأزرار في Row (صف) إذا كانت الشركة صالحة
                                if(isCompanyValid)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 2. زر الخريطة 
                                      ElevatedButton.icon(
                                        onPressed: controller.openMap, 
                                        icon: const Icon(Icons.map_outlined),
                                        label: Text(isArabic
                                            ? 'الخريطة'
                                            : 'Map'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryYellowColor, 
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // 3. 🎯 زر الحفظ (SAVE BUTTON) 
                                      ElevatedButton.icon(
                                        onPressed: controller.saveCurrentCompany, 
                                        icon: const Icon(Icons.favorite),
                                        label: Text(isArabic
                                            ? 'حفظ'
                                            : 'Save'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryYellowColor, 
                                          foregroundColor: Colors.black, 
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
],
 ),
 );
}
 return const SizedBox.shrink(); // لا شيء لعرضه
 }),
], ),
),
],
),
),
),
);
});
}
}