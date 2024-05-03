import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/const.dart';
import 'package:login_flutter/util/permission_helper.dart';
import 'package:login_flutter/util/toast.dart';

class AvatarPicker {
  Future<String> openImagePicker() async {
    final isGranted = await PermissionHelper.requestAlbumPermission();
    if (isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image?.path ?? '';
    } else {
      MyToast.showToast(
        msg: TOAST_PHOTO_PERMISSION_DENIED,
        type: ToastType.error,
      );
      return "";
    }
  }
}
