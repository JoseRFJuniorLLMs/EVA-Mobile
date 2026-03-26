import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> requestCallPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    return statuses[Permission.microphone]!.isGranted;
  }
}
