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
  // mock default admin user id
  static const int _defaultAdminID = 1;

  static Future<void> initialDataBase() async {
    openDatabase(
      singleInstance: true,
      join(await getDatabasesPath(), DB_NAME),
      onCreate: _onCreateChatsTable,
      version: 2,
    );

    debugPrint("${await getDatabasesPath()}/$DB_NAME");
  }

  static Future<void> _onCreateChatsTable(Database db, int version) async {
    // create users table
    await db.execute("""

        CREATE TABLE Users (
            user_id INTEGER PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            other_user_details TEXT
        );
      """);

    //  create messages table
    //  timestamp -- Store as ISO8601 string ("YYYY-MM-DD HH:MM:SS.SSS")
    //  sender_id -- Foreign key to Users table
    //  recipient_id -- Foreign key to Users table
    //  message_content -- Text message content

    await db.execute("""
        CREATE TABLE Messages (
            message_id INTEGER PRIMARY KEY,
            sender_id INTEGER NOT NULL,
            recipient_id INTEGER NOT NULL,
            message_content TEXT,
            timestamp TEXT,
            FOREIGN KEY (sender_id) REFERENCES Users(user_id),
            FOREIGN KEY (recipient_id) REFERENCES Users(user_id)
        );
      """);

    // insert default admin user
    await db.execute("""
    INSERT INTO Users (email, other_user_details)
    VALUES ('admin@admin.com', 'admin');
""");
  }

  static Future<List<ChatMessage>> getAllChatMessages() async {
    var db = await openDatabase(DB_NAME);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final email = prefs.getString(ADMIN_EMAIL) ?? '';

    final currentUserId = await _getOrCreateUserInfoByEmail(email);

    // 使用 SQL 查询获取所有相关聊天消息，按时间戳降序排列
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT *
    FROM Messages
    WHERE sender_id = ? OR recipient_id = ?
    ORDER BY timestamp DESC
  ''', [currentUserId, currentUserId]);

    // 将查询结果转换为 ChatMessage 对象列表
    return List.generate(maps.length, (i) {
      return ChatMessage(
        senderId: maps[i]['sender_id'],
        receiverId: maps[i]['recipient_id'],
        messageContent: maps[i]['message_content'],
        timestamp: maps[i]['timestamp'],
      );
    });
  }

  // 通过 email 查询用户信息 ,  如果没有查询到结果，则插入新用户并返回用户信息
  static Future<int> _getOrCreateUserInfoByEmail(String email) async {
    var db = await openDatabase(DB_NAME);

    // 使用 email 查询用户信息
    List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT * 
    FROM Users 
    WHERE email = ?
  ''', [email]);

    // 如果查询到结果，则将数据转换为 User 对象并返回
    if (results.isNotEmpty) {
      return results.first['user_id'];
    }

    // 如果没有查询到结果，则插入新用户并返回用户信息
    int newUserId = await db.rawInsert('''
    INSERT INTO Users (email)
    VALUES (?)
  ''', [email]);

    return newUserId;
  }

  // save chat message to database, return true if success, false if failed
  static Future<ChatMessage?> saveChatMessage(
      String message, int userId) async {
    if (message.isEmpty) return null;

    var db = await openDatabase(DB_NAME);

    // 所有消息的接受者为default admin  user_id = 1
    // 实际场景中，接受者应该是当前登录用户的 user_id

    final String timestamp = DateTime.now().toIso8601String();

    try {
      // 插入一条聊天消息
      await db.rawInsert("""
        INSERT INTO Messages (sender_id, recipient_id, message_content, timestamp)
        VALUES (?, ?, ?, ?)
        """, [userId, _defaultAdminID, message, timestamp]);

      return ChatMessage(
        messageContent: message,
        senderId: userId,
        receiverId: _defaultAdminID,
        timestamp: timestamp,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<User> onUserLogin(
      String name, String password, UserType type) async {
    // use shared preferences to save user info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, _mockUserToken);
    prefs.setString(USER_NAME, name);
    prefs.setInt(USER_TYPE, type.index);

    return User(
      name: name,
      token: _mockUserToken,
      type: type,
      avatarPath: '',
      email: '',
      userID: -1,
    );
  }

//danteng@dan.com
  static Future<User> onAdminLogin(
      {required String email, required String password}) async {
    // use shared preferences to save admin info
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_TOKEN, _mockUserToken);
    prefs.setString(ADMIN_EMAIL, email);
    prefs.setInt(USER_TYPE, UserType.admin.index);

    // get or create user to users table
    final int userId = await _getOrCreateUserInfoByEmail(email);
    prefs.setInt(ADMIN_ID, userId);

    await _createDefaultHelloToUser(userId);

    final user = User(
      name: '',
      token: _mockUserToken,
      type: UserType.admin,
      avatarPath: '',
      email: email,
      userID: userId,
    );
    debugPrint(
      'admin login success user info: name: ${user.name}, email: ${user.email}, token: ${user.token}, type: ${user.type}, userID: ${user.userID}',
    );

    return user;
  }

  static Future<void> _createDefaultHelloToUser(int userId) async {
    var db = await openDatabase(DB_NAME);
    final String timestamp = DateTime.now().toIso8601String();

    try {
      // 插入一条聊天消息
      await db.rawInsert("""
        INSERT INTO Messages (sender_id, recipient_id, message_content, timestamp)
        VALUES (?, ?, ?, ?)
        """, [_defaultAdminID, userId, 'Hello to you!', timestamp]);
    } catch (e) {
      debugPrint(e.toString());
    }
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
    final int adminId = prefs.getInt(ADMIN_ID) ?? -1;

    if (name.isEmpty && email.isEmpty) {
      return null;
    }

    final user = User(
      name: name,
      token: token,
      type: UserType.values[type],
      avatarPath: avatarPath,
      email: email,
      userID: adminId,
    );

    debugPrint(
        'get user info from local: user info: name: ${user.name}, email: ${user.email}, token: ${user.token}, type: ${user.type}, userID: ${user.userID}');
    return user;
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
