import 'package:flutter/material.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/util/local_data_storage.dart';

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database.
  await LocalDataBase.initialDataBase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}
