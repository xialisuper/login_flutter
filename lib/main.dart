import 'package:flutter/material.dart';
import 'package:login_flutter/Admin/admin_page.dart';
import 'package:login_flutter/User/user_page.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/util/local_data_storage.dart';

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database.
  await LocalDataBase.initialDataBase();

  final user = await LocalDataBase.getUserInfo();

  runApp(MainApp(userType: user?.type));
}

class MainApp extends StatelessWidget {
  final UserType? userType;

  const MainApp({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (userType == null) {
      home = const LoginPage();
    } else if (userType == UserType.admin) {
      home = const AdminPage();
    } else {
      home = const UserPage();
    }

    
    return MaterialApp(home: home);
  }
}
