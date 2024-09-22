// Package imports:
import 'package:permission_handler/permission_handler.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted
}

class NotificationPermissionsHandler {
  Future<bool> get isGranted async {
    final status = await Permission.notification.status;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return false;
      default:
        return false;
    }
  }

  Future<NotificationPermissionStatus> request() async {
    final status = await Permission.notification.request();
    switch (status) {
      case PermissionStatus.granted:
        return NotificationPermissionStatus.granted;
      case PermissionStatus.denied:
        return NotificationPermissionStatus.denied;
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return NotificationPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return NotificationPermissionStatus.restricted;
      default:
        return NotificationPermissionStatus.denied;
    }
  }
}
