import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/style/colors.dart';

class NotificationService {

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null,
      [
        NotificationChannel(
          channelKey: 'notification',
          channelName: '3 Days Reminder Notifications',
          channelDescription: 'Notification channel for 3 days reminder',
          defaultColor: AppColor.blue,
          importance: NotificationImportance.Max,
          playSound: true,
        )
      ],
    );
  }



  Future<void> createNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:DateTime.now().second,
        channelKey: 'notification',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
