import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

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
    Permission permissionToRequest = Permission.photos;

    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();

      final deviceInfo = await deviceInfoPlugin.deviceInfo as AndroidDeviceInfo;

      // android sdk version <= 32 , photo permission should call storage permission
      // over 33 , photo permission is enough
      if (deviceInfo.version.sdkInt <= 32) {
        permissionToRequest = Permission.storage;
      }
    }


    // hasPermission 已经获取到权限
    if (await permissionToRequest.status.isGranted ||
        await permissionToRequest.status.isLimited) return true;

    // 请求权限
    final status = await permissionToRequest.request();

    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return true;
    }

    return false;
  }
}
