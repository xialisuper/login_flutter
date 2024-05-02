import 'package:flutter/material.dart';
import 'package:login_flutter/User/user_page.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/util/local_data_storage.dart';

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database.
  await LocalDataBase.initialDataBase();

  final user = await LocalDataBase.getUserInfo();
  final isLogin = user != null;

  runApp(MainApp(isLogin: isLogin));
}

class MainApp extends StatelessWidget {
  final bool isLogin;

  const MainApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLogin ? const UserPage() : const LoginPage(),
    );
  }
}
