import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/controllers/reading_controller.dart';

class ReadingScreen extends StatelessWidget{

  final  controller = Get.put(ReadingController());

  ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      // bottomNavigationBar: Container(
      //   decoration:  BoxDecoration(
      //     border: Border(top: BorderSide(color: AppColor.black)),
      //   ),
      //   child: BottomNavigationBar(
      //     iconSize: 30,
      //     backgroundColor: AppColor.white,
      //     type: BottomNavigationBarType.fixed,
      //     selectedItemColor: AppColor.black,
      //     unselectedItemColor: AppColor.black,
      //     showSelectedLabels: true,
      //     showUnselectedLabels: true,
      //     items: const [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home_outlined),
      //         label: "Home",
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.bar_chart_outlined),
      //         label: "Usage",
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.power_outlined),
      //         label: "Power Usage",
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.history),
      //         label: "History",
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                  children: [
                    // header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColor.primary_color,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(120),
                          bottomRight: Radius.circular(120),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(Icons.arrow_back, color: AppColor.black, size: 28),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Implement logout functionality here
                                },
                                icon: Icon(Icons.logout, color: AppColor.black, size: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'ادخل القراءة',
                            style: TextStyle(
                              color: AppColor.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // upload box section
                    GestureDetector(
                      onTap: () => controller.pickImage(ImageSource.gallery),
                      child: Obx((){
                        if (controller.pickedImage.value != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              controller.pickedImage.value!,
                              fit: BoxFit.cover,
                              width: 300,
                              height: 160,
                            ),
                          );
                        } else {
                          return Container(
                            width: 300,
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.black,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => controller.pickImage(ImageSource.gallery),
                                    icon: Icon(Icons.upload_file, size: 50, color: AppColor.black),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'تحميل',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                    const SizedBox(height: 20),
                    // input field with mic & camera
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: AppColor.gray
                        ),
                      ),
                      child:Row(
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: AppColor.black,
                              decoration: InputDecoration(
                                hintText: 'ادخل هنا كتابة او باستخدام الكاميرا او الميكروفون',
                                border: InputBorder.none,
                                // suffixText: 'kWh',
                              ),
                              controller: controller.textController,
                              style: TextStyle(
                                color: AppColor.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.recognizeVoice,
                            icon: Icon(Icons.mic, color: AppColor.black),
                          ),
                          IconButton(
                            onPressed: () => controller.pickImage(ImageSource.camera),
                            icon: Icon(Icons.camera_alt, color: AppColor.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // calculate button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary_color,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        // controller.processInput();
                      },
                      child: Text(
                        'احسب',
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ),
                    // const SizedBox(height: 30),
                    // // display final text
                    // Obx(()=> controller.finalText.value.isNotEmpty
                    //   ? Padding(
                    //       padding: const EdgeInsets.all(16.0),
                    //       child: Text(
                    //         'Reading: ${controller.finalText.value}',
                    //         textAlign: TextAlign.center,
                    //         style:TextStyle(
                    //           color: AppColor.black,
                    //           fontSize: 18,
                    //         ),
                    //       ),
                    //     )
                    //   : const SizedBox()),
                  ])
          )
      ),
    );
  }
}