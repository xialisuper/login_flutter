import 'package:flutter/material.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/util/local_data_storage.dart';

class UserModel with ChangeNotifier {
  User? _userInfo;

  User? get userInfo => _userInfo;

  void setUserInfo(User userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  Future<void> logOut() async {
    _userInfo = null;
    await LocalDataBase.deleteAllDataFromSharedPrefs();
    notifyListeners();
  }

  Future<void> userLogin(
      String username, String password, UserType type) async {
    final user = await LocalDataBase.onUserLogin(username, password, type);

    _userInfo = user;
    notifyListeners();
  }

  Future<void> adminLogin(
      {required String email, required String password}) async {
    final user = await LocalDataBase.onAdminLogin(
      email: email,
      password: password,
    );

    _userInfo = user;
    notifyListeners();
  }

  Future<void> updateUserAvatarPath(String path) async {
    if (_userInfo == null) return;

    userInfo!.avatarPath = path;
    notifyListeners();

    // save user avatar path to shared preferences. no need to await.
    // may not work in web according to doc.
    return LocalDataBase.setUserAvatarPath(path);
  }
}
