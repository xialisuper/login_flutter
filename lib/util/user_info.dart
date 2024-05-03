import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  UserInfo? _userInfo;

  UserInfo? get userInfo => _userInfo;

  void setUserInfo(UserInfo userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  void logOut() {
    _userInfo = null;
    notifyListeners();
  }
}

class UserInfo {
  String name;
  String email;
  int userId;

  UserInfo({
    required this.name,
    required this.email,
    required this.userId,
  });
}
