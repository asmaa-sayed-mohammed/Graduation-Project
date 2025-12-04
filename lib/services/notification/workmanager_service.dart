import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.createNotification('ادخل القراءة', 'تذكير بادخال قراءة العداد');
    return Future.value(true);
  });
}

class WorkManagerService {
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  void registerPeriodicNotificationAtTime() {
    const targetHour = 13;

    DateTime now = DateTime.now();
    DateTime nextRun = DateTime(
      now.year,
      now.month,
      now.day,
      targetHour,
    );

    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add( Duration(days: 1));
    }

    Duration initialDelay = nextRun.difference(now);

    Workmanager().registerPeriodicTask(
      "reminder_at_specific_time",
      "3_Day_Reminder_Task",
      frequency:  Duration(days: 3),
      initialDelay: initialDelay,
    );
  }
}
