import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  static Future<void> requestCameraPermission() async {
    // hasPermission 已经获取到权限
    if (await Permission.camera.status.isGranted) return;

    // 请求权限
    final status = await Permission.camera.request();

    // 如果用户拒绝了权限，则会返回 denied
    if (status == PermissionStatus.denied) {
      // 显示用户拒绝的提示信息
    }
  }
}
