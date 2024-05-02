// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:login_flutter/Admin/admin_page.dart';
import 'package:login_flutter/User/user_page.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/qrcode/qrcode_page.dart';
import 'package:login_flutter/util/local_data_storage.dart';
import 'package:login_flutter/util/toast.dart';

import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAdmin = false;
  bool isStudent = true;

  // controller for admin login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // controller for user login
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    userPasswordController.dispose();
    super.dispose();
  }

  // This method handles the form submission for admin login.
  void _onAdminSubmit() {
    if (!_isValidatedEmail(emailController.text)) {
      _showError("Please enter a valid email address");
      return;
    }

    if (!_isValidatedPassword(passwordController.text)) {
      _showError("Please enter a valid password, length is at least 6");
      return;
    }

    // Navigate to the admin page on successful login.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPage(),
      ),
    );
  }

  // This method handles the form submission for user login.
  Future<void> _onUserSubmit() async {
    if (!_isValidatedUserName(userNameController.text)) {
      _showError("Please enter a valid user name, length is at least 6");
      return;
    }

    if (!_isValidatedPassword(userPasswordController.text)) {
      _showError("Please enter a valid password, length is at least 6");
      return;
    }

    // save user info to local database
    await LocalDataBase.onUserLoginWithName(
      userNameController.text,
      userPasswordController.text,
      isStudent ? UserType.student : UserType.parent,
    );

    // Navigate to the user page on successful login.
    if (!mounted) return;
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const UserPage()),
      ModalRoute.withName('/'),
    );
  }

  // Display an error message using a snackbar.
  void _showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(errorMessage),
      ),
    );
  }

  // Validate the length of the user name.
  bool _isValidatedUserName(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.length >= 6;
  }

  // Validate the email using a regular expression.
  bool _isValidatedEmail(String? value) {
    RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value ?? '');
  }

  // Validate the length of the password.
  bool _isValidatedPassword(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.length >= 6;
  }

  // Handle the change in login type (admin/user) and update the UI accordingly.
  void _handleLoginTypeChange(bool isAdmin) {
    if (this.isAdmin == isAdmin) return;
    return setState(() {
      this.isAdmin = isAdmin;
    });
  }

  Future<void> _handleQrCodeButtonClicked() async {
    final defaultStatus = await Permission.camera.status;
    if (defaultStatus.isGranted) {
      _goToQrCodeScanPage();
    } else {
      final status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {
        debugPrint('获取到权限 准备处理扫码');
        _goToQrCodeScanPage();
      } else {
        debugPrint('拒绝权限 提示用户拒绝权限');
        MyToast.showToast(msg: '相册权限未开启，请开启权限后再扫码', type: ToastType.error);
      }
    }
  }

  // 跳转到 QR 码扫描页面
  void _goToQrCodeScanPage() {
    debugPrint('跳转到 QR 码扫描页面');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QRCodePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            const Placeholder(
              fallbackHeight: 200,
            ),
            const SizedBox(height: 20),

            _LoginSectionSwitcher(
                onSelectButtonClicked: _handleLoginTypeChange),

            // scrollable line
            _AnimateScrollableLineIndicator(isAdmin: isAdmin),

            //  forms
            const SizedBox(height: 20),

            isAdmin
                ? _AdminLoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                    onSubmit: _onAdminSubmit,
                  )
                : _UserLoginForm(
                    userNameController: userNameController,
                    userPasswordController: userPasswordController,
                    onSubmit: _onUserSubmit,
                    isStudent: isStudent,
                    onSelectButtonClicked: (bool isStudent) {
                      setState(() {
                        this.isStudent = isStudent;
                      });
                    }),

            // QR CODE BUTTON
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[400],
              ),
              onPressed: _handleQrCodeButtonClicked,
              child: const Text('Login By QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginSectionSwitcher extends StatelessWidget {
  const _LoginSectionSwitcher({
    super.key,
    required this.onSelectButtonClicked,
  });

  final Function(bool isAdmin) onSelectButtonClicked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onSelectButtonClicked(false),
              child: Center(child: Text('User')),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onSelectButtonClicked(true),
              child: Center(
                child: Text('Admin'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimateScrollableLineIndicator extends StatelessWidget {
  const _AnimateScrollableLineIndicator({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Theme.of(context).hintColor.withOpacity(0.2),
        ),
        width: constraints.maxWidth,
        height: 4,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              width: 0.5 * constraints.maxWidth,
              height: 4,
              left: isAdmin ? 0.5 * constraints.maxWidth : 0,
              curve: Curves.easeInOut,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: Colors.yellow[400]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _UserLoginForm extends StatelessWidget {
  const _UserLoginForm({
    required this.userNameController,
    required this.userPasswordController,
    required this.onSubmit,
    required this.isStudent,
    required this.onSelectButtonClicked,
    // required ValueKey<String> key,
  });

  final TextEditingController userNameController;
  final TextEditingController userPasswordController;
  final VoidCallback onSubmit;
  final bool isStudent;
  final Function(bool) onSelectButtonClicked;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => onSelectButtonClicked(true),
            child: Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isStudent
                    ? const Color.fromRGBO(179, 229, 224, 1)
                    : Theme.of(context).hintColor.withOpacity(0.2),
              ),
              child: const Center(child: Text('Student')),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onSelectButtonClicked(false),
            child: Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isStudent
                    ? Theme.of(context).hintColor.withOpacity(0.2)
                    : const Color.fromRGBO(179, 229, 224, 1),
              ),
              child: const Center(child: Text('Parent')),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          controller: userNameController,
          placeholder: 'User Name',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          controller: userPasswordController,
          obscureText: true,
          placeholder: 'Password',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onSubmit,
          child: const Text('LOGIN'),
        ),
      )
    ]);
  }
}

class _AdminLoginForm extends StatelessWidget {
  const _AdminLoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    // required ValueKey<String> key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          controller: emailController,
          placeholder: 'Email',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          controller: passwordController,
          obscureText: true,
          placeholder: 'Password',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onSubmit,
          child: const Text('LOGIN'),
        ),
      )
    ]);
  }
}
