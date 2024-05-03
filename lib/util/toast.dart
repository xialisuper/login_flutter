//  enum error info success
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_flutter/const.dart';

enum ToastType { error, info, success }

class MyToast {
  static Future<bool?> showToast({
    required String msg,
    ToastType type = ToastType.info,
  }) {
    final Color backgroundColor;

    switch (type) {
      case ToastType.error:
        backgroundColor = Colors.red;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue;
        break;
      case ToastType.success:
        backgroundColor = Colors.green;
        break;
    }

    return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: TOAST_DURATION_SECONDS,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
