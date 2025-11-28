import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;

  if (status.isDenied) {
    status = await Permission.notification.request();
  }

  if (status.isPermanentlyDenied) {
    /// Open app settings to enable notifications manually
    await openAppSettings();
  }
}

