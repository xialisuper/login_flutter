import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/util/local_data_storage.dart';
import 'package:login_flutter/util/permission_helper.dart';
import 'package:login_flutter/util/toast.dart';
import 'package:login_flutter/util/user_info.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _userName = '';
  String _userAvatarPath = '';

  Future<void> _handleUserIconButtonTapped() async {
    final isGranted = await PermissionHelper.requestCameraPermission();
    if (isGranted) {
      _openImagePicker();
    } else {
      MyToast.showToast(msg: '相册权限未授权', type: ToastType.error);
    }
  }

  Future<void> _openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    // 从相册中选择图片
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      setState(() {
        _userAvatarPath = image.path;
      });
      // 保存用户头像到shared preferences. no need to await
      // may not work in web .
      LocalDataBase.setUserAvatarPath(image.path);
    }
  }

  Future<void> _loadUserInfo() async {
    final User? user = await LocalDataBase.getUserInfo();

    if (user != null) {
      setState(() {
        debugPrint('user: ${user.toString()}');

        _userName = user.name;
        _userAvatarPath = user.avatarPath;
      });
    }
  }

  Future<void> _backToLoginPage(BuildContext context) async {
    //clear user info and logout
    await LocalDataBase.onUserLogOut();

    if (!context.mounted) return;

    Provider.of<UserModel>(context, listen: false).logOut();

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage()),
      ModalRoute.withName('/login'),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
            if (_userAvatarPath.isNotEmpty)
              GestureDetector(
                onTap: _handleUserIconButtonTapped,
                child: CircleAvatar(
                  radius: 100, // 设置头像半径
                  backgroundImage:
                      FileImage(File(_userAvatarPath)), // 使用FileImage加载图片
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
            // user name
            Text(
              _userName.isNotEmpty ? _userName : 'hello world',
              style: const TextStyle(fontSize: 20),
            ),
            const Spacer(),
            // log out button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () => _backToLoginPage(context),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
