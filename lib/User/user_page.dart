import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/login/login_page.dart';

import 'package:login_flutter/util/permission_helper.dart';
import 'package:login_flutter/util/toast.dart';
import 'package:login_flutter/util/user_model.dart';
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
    final isGranted = await PermissionHelper.requestAlbumPermission();
    if (isGranted) {
      _openImagePicker();
    } else {
      MyToast.showToast(msg: '相册权限未授权', type: ToastType.error);
    }
  }

  Future<void> _openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      setState(() {
        _userAvatarPath = image.path;
      });

      if (!mounted) return;
      Provider.of<UserModel>(context).updateUserAvatarPath(image.path);
    }
  }

  Future<void> _loadUserInfo() async {
    final user = Provider.of<UserModel>(context).userInfo;

    if (user != null) {
      setState(() {
        debugPrint('user: ${user.toString()}');

        _userName = user.name;
        _userAvatarPath = user.avatarPath;
      });
    }
  }

  Future<void> _handleLogOutButtonTapped(BuildContext context) async {
    // must await to ensure the logOut method is completed before push the login page
    await Provider.of<UserModel>(context, listen: false).logOut();
    if (!context.mounted) return;
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
  }

  @override
  void didChangeDependencies() {
    _loadUserInfo();
    super.didChangeDependencies();
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
                onPressed: () => _handleLogOutButtonTapped(context),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
