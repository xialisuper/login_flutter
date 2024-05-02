import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/util/local_data_storage.dart';
import 'package:login_flutter/util/permission_helper.dart';
import 'package:login_flutter/util/toast.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _imageFilePath = '';

  Future<void> _handleUserIconButtonTapped() async {
    final isGranted = await PermissionHelper.requestCameraPermission();
    if (isGranted) {
      _openImagePicker();
    } else {
      debugPrint('相册权限未授权');
      MyToast.showToast(msg: '相册权限未授权', type: ToastType.error);
    }
  }

  Future<void> _openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    // 从相册中选择图片
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      setState(() {
        _imageFilePath = image.path;
      });
      // 保存用户头像到shared preferences. no need to await
      // may not work in web .
      LocalDataBase.setUserAvatarPath(image.path);
    }
  }

  Future<void> loadImagePath() async {
    final String? imagePath = await LocalDataBase.getUserAvatarPath();
    if (imagePath != null) {
      setState(() {
        _imageFilePath = imagePath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            if (_imageFilePath.isNotEmpty)
              GestureDetector(
                onTap: _handleUserIconButtonTapped,
                child: CircleAvatar(
                  radius: 100, // 设置头像半径
                  backgroundImage:
                      FileImage(File(_imageFilePath)), // 使用FileImage加载图片
                ),
              )
            else
              IconButton(
                onPressed: _handleUserIconButtonTapped,
                icon: const Icon(
                  size: 200,
                  Icons.enhance_photo_translate_rounded,
                ),
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
