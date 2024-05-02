import 'dart:io';

import 'package:login_flutter/const.dart';
import 'package:login_flutter/model/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalDataBase {
  static Future<void> initialDataBase() async {
    openDatabase(
      singleInstance: true,
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, token TEXT)',
        );
      },

      version: 1,
    );
  }

  static Future<Database> _getDatabase() async {
    var db = await openDatabase(DB_NAME);
    return db;
  }

  static Future<void> onUserLoginWithName(
      String name, String password, UserType type) async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, _mockUserToken);
    prefs.setString(USER_NAME, name);
    prefs.setInt(USER_TYPE, type.index);
  }

  static Future<void> _saveUserNameAndToken(String name, String token) async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, token);
    prefs.setString(USER_NAME, name);
  }

  Future<String> saveImageToFileSystem(File imageFile, String filename) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File newImage = await imageFile.copy('$path/$filename');
    return newImage.path;
  }

  Future<void> _saveImagePath(String imagePath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_AVATAR_PATH, imagePath);
  }

  Future<String?> _getImagePath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_AVATAR_PATH);
  }

  static Future<User?> getUserInfo() async {
    // use shared preferences to get user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString(USER_NAME) ?? '';
    final String token = prefs.getString(USER_TOKEN) ?? '';
    final int type = prefs.getInt(USER_TYPE) ?? 0;

    if (name.isEmpty || token.isEmpty) {
      return null;
    }

    return User(
      name: name,
      token: token,
      type: UserType.values[type],
    );
  }

  //
  // static Future<User?> _queryUserWithName(String name) async {
  //   var db = await _getDatabase();
  //   final List<Map> result = await db.rawQuery(
  //     'SELECT * FROM users WHERE name = ?',
  //     [name],
  //   );

  //   if (result.isEmpty) {
  //     return null;
  //   }

  //   return User(
  //     name: result[0]['name'],
  //     token: result[0]['token'],
  //     type: UserType.values[result[0]['type']],
  //   );
  // }
}

const String _mockUserToken = '1234567890';
