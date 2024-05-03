import 'dart:io';

import 'package:flutter/material.dart';

import 'package:login_flutter/User/image_picker.dart';
import 'package:login_flutter/login/login_page.dart';

import 'package:login_flutter/util/user_model.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<void> _handleUserIconButtonTapped() async {
    // picker will check permission or request permission and then open image picker , return selected image path or empty string(canceled)
    final path = await Provider.of<AvatarPicker>(context, listen: false)
        .openImagePicker();


    // if user canceled the picker, return
    if (path.isEmpty) return;

    if (!mounted) return;
    // update user avatar path
    // should use listen: false to use context outside widget tree
    await Provider.of<UserModel>(context, listen: false)
        .updateUserAvatarPath(path);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Center(
        child: Consumer<UserModel>(builder: (_, userModel, __) {
          return Column(
            children: <Widget>[
              // if (_userAvatarPath.isNotEmpty)
              if (userModel.userInfo != null &&
                  userModel.userInfo!.avatarPath.isNotEmpty)
                GestureDetector(
                  onTap: _handleUserIconButtonTapped,
                  child: CircleAvatar(
                    radius: 100, // 设置头像半径
                    backgroundImage: FileImage(File(
                        userModel.userInfo!.avatarPath)), // 使用FileImage加载图片
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

              Text(
                _userName(userModel),
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () => _handleLogOutButtonTapped(context),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _userName(UserModel userModel) {
    if (userModel.userInfo == null) return 'hello world';
    if (userModel.userInfo!.name.isEmpty) return 'hello world';
    return ' name is ${userModel.userInfo!.name} \n identity is ${userModel.userInfo!.type}';
  }
}
