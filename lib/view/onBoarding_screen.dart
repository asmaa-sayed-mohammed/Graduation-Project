import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/services/auth_service.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/start_screen.dart';
import '../main.dart';
import '../core/widgets/page_header.dart';


class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  final List<Map<String, String>> pages = [
    {
      'title': 'مرحبا بك',
      'subtitle': 'ابدأ رحلتك معنا',
      'image': 'assets/images/On_boarding1.png',
    },
    {
      'title': 'تعلّم بسهولة',
      'subtitle': 'الوصول لكل المعلومات بسهولة',
      'image': 'assets/images/On_boarding2.png',
    },
    {
      'title': 'ابدأ الآن',
      'subtitle': 'انطلق مع تطبيقنا',
      'image': 'assets/images/On_boarding3.png',
    },
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white2,
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = pages[index];
                return Column(
                  children: [
                    PageHeader(
                      title: page['title']!,
                      subtitle: page['subtitle']!,
                      trailing: TextButton(
                        onPressed: () {
                          onboarding.put('isComplete', true);
                          final logged = AuthService().isLoggedIn();
                          Get.off(() => logged ? StartScreen() : Homescreen());
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                              color: AppColor.black, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          page['image']!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Indicators و أزرار التنقل
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      pages.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index ? AppColor.black : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // زر التنقل
                  currentPage == pages.length - 1
                      ? Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          onboarding.put('isComplete', true);
                          final logged = AuthService().isLoggedIn();
                          Get.off(() => logged ? StartScreen() : Homescreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'اذهب للصفحة الرئيسية',
                          style: TextStyle(
                              color: AppColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: AppColor.white),
                        ],
                      ),
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
