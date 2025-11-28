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

  void registerPeriodicNotification() {
    Workmanager().registerPeriodicTask(
        DateTime.now().second.toString(),
      "3 Days Reminder",
      frequency: const Duration(days: 3),
    );
  }
}
