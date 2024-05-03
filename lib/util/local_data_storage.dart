import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:login_flutter/const.dart';
import 'package:login_flutter/model/chat_message.dart';
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
      onCreate: _onCreateChatsTable,
      version: 2,
    );

    debugPrint("${await getDatabasesPath()}/$DB_NAME");
  }

  static Future<void> _onCreateChatsTable(Database db, int version) async {
    await db.execute(
        'CREATE TABLE chats (id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, isSentByUser INTEGER)');
    await db.rawInsert(
        'INSERT INTO chats (content, isSentByUser) VALUES (?, ?)',
        ['hello world', 0]);
  }

  static Future<List<ChatMessage>> getAllChatMessages() async {
    var db = await openDatabase(DB_NAME);

    // get all chat messages and descent order
    final List<Map> result = await db.rawQuery(
      'SELECT * FROM chats ORDER BY id DESC',
    );

    if (result.isEmpty) {
      return [];
    }

    return result.map((e) {
      return ChatMessage(
        content: e['content'],
        isSentByUser: e['isSentByUser'] == 1 ? true : false,
      );
    }).toList();
  }

  static Future<void> saveChatMessage(ChatMessage message) async {
    var db = await openDatabase(DB_NAME);
    final int id = await db.rawInsert(
        'INSERT INTO chats (content, isSentByUser) VALUES (?, ?)',
        [message.content, message.isSentByUser ? 1 : 0]);
    debugPrint('saveChatMessage id: $id');
  }

  static Future<void> onUserLoginWithName(
      String name, String password, UserType type) async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, _mockUserToken);
    prefs.setString(USER_NAME, name);
    prefs.setInt(USER_TYPE, type.index);
  }

  static Future<void> onAdminLogin(
      {required String email, required String password}) async {
    // use shared preferences to save admin info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, _mockUserToken);
    prefs.setString(ADMIN_EMAIL, email);
    prefs.setInt(USER_TYPE, UserType.admin.index);
  }

  static Future<void> onUserLogOut() async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_TOKEN);
    prefs.remove(USER_NAME);
    prefs.remove(USER_TYPE);
    prefs.remove(USER_AVATAR_PATH);
  }

  static Future<void> onAdminLogOut() async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_TOKEN);
    prefs.remove(ADMIN_EMAIL);
    prefs.remove(USER_TYPE);
    prefs.remove(USER_AVATAR_PATH);
  }

  Future<String> saveImageToFileSystem(File imageFile, String filename) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File newImage = await imageFile.copy('$path/$filename');
    return newImage.path;
  }

  static Future<User?> getUserInfo() async {
    // use shared preferences to get user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString(ADMIN_EMAIL) ?? '';
    final String name = prefs.getString(USER_NAME) ?? '';
    final String token = prefs.getString(USER_TOKEN) ?? '';
    final int type = prefs.getInt(USER_TYPE) ?? 0;
    final String avatarPath = prefs.getString(USER_AVATAR_PATH) ?? '';

    if (name.isEmpty && email.isEmpty) {
      return null;
    }

    return User(
      name: name,
      token: token,
      type: UserType.values[type],
      avatarPath: avatarPath,
      email: email,
    );
  }

  static Future<void> setUserAvatarPath(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_AVATAR_PATH, path);
  }

  static Future<String?> getUserAvatarPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_AVATAR_PATH);
  }
}

const String _mockUserToken = '1234567890';
