import 'package:flutter/material.dart';

import 'package:login_flutter/Admin/admin_page.dart';
import 'package:login_flutter/User/image_picker.dart';
import 'package:login_flutter/User/user_page.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/util/local_data_storage.dart';
import 'package:login_flutter/util/user_model.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database.
  await LocalDataBase.initialDataBase();

  final user = await LocalDataBase.getUserInfo();

  runApp(
    // put the user information to the provider. and pass it to the main app. so that it can be used in the whole app.
    ChangeNotifierProvider(
      create: (BuildContext context) => UserModel(),
      child: MainApp(user),
    ),
  );
}

class MainApp extends StatelessWidget {
  final User? user;

  const MainApp(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        // Set the user information to the provider.
        Provider.of<UserModel>(context, listen: false).setUserInfo(user!);
      }
    });

    Widget home;
    if (user == null) {
      home = const LoginPage();
    } else if (user!.type == UserType.admin) {
      home = const AdminPage();
    } else {
      home = Provider(
        create: (BuildContext context) => AvatarPicker(),
        child: const UserPage(),
      );
    }

    return MaterialApp(
      home: home,
    );
  }
}
