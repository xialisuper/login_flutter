import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  //  requestCameraPermission 检查相机权限
  static Future<bool> requestCameraPermission() async {
    if (await Permission.camera.status.isGranted) return true;

    final status = await Permission.camera.request();

    // 如果用户拒绝了权限，则会返回 denied
    if (status == PermissionStatus.granted) {
      // 显示用户拒绝的提示信息
      return true;
    } else {
      return false;
    }
  }

  // 请求相册权限
  static Future<bool> requestAlbumPermission() async {
    // hasPermission 已经获取到权限
    if (await Permission.photos.status.isGranted || await Permission.photos.status.isLimited) return true;

    // 请求权限
    final status = await Permission.photos.request();

    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return true;
    }

    return false;
  }

 
}
