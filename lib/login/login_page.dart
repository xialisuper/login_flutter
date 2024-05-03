// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:login_flutter/Admin/admin_page.dart';
import 'package:login_flutter/User/user_page.dart';
import 'package:login_flutter/const.dart';
import 'package:login_flutter/model/user.dart';
import 'package:login_flutter/qrcode/qrcode_page.dart';
import 'package:login_flutter/util/qr_helper.dart';

import 'package:login_flutter/util/toast.dart';
import 'package:login_flutter/util/user_model.dart';
import 'package:login_flutter/util/validations.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
  Future<void> _onAdminSubmit() async {
    if (!Validations.isValidatedEmail(emailController.text)) {
      _showError(TOAST_INVALID_EMAIL);
      return;
    }

    if (!Validations.isValidatedPassword(passwordController.text)) {
      _showError(TOAST_INVALID_PASSWORD);
      return;
    }

    _showSuccess(TOAST_SUCCESS_MESSAGE);

    // UserModel handle admin login event
    await Provider.of<UserModel>(context, listen: false).adminLogin(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    // Navigate to the user page on successful login.
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AdminPage(),
      ),
      ModalRoute.withName('/admin'),
    );
  }

  // This method handles the form submission for user login.
  Future<void> _onUserSubmit() async {
    if (!Validations.isValidatedUserName(userNameController.text)) {
      _showError(TOAST_INVALID_USERNAME);
      return;
    }

    if (!Validations.isValidatedPassword(userPasswordController.text)) {
      _showError(TOAST_INVALID_PASSWORD);
      return;
    }

    _showSuccess(TOAST_SUCCESS_MESSAGE);

    // UserModel handle user login event
    await Provider.of<UserModel>(context, listen: false).userLogin(
      userNameController.text,
      userPasswordController.text,
      isStudent ? UserType.student : UserType.parent,
    );
    if (!mounted) return;

    // Navigate to the user page on successful login.
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const UserPage()),
      ModalRoute.withName('/user'),
    );
  }

  // Display an error message using a snackbar.
  void _showError(String errorMessage) {
    MyToast.showToast(msg: errorMessage, type: ToastType.error);

    // show snackbar
    // if is debug mode

    if (kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String successMessage) {
    MyToast.showToast(msg: successMessage, type: ToastType.success);
    // show snackbar for widget test in debug mode
    // flutter toast can not be found in widget test
    // because it does not use the context
    if (kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        builder: (context) => Provider(
          create: (BuildContext context) => QRHelper(),
          child: const QRCodePage(),
        ),
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
              onSelectButtonClicked: _handleLoginTypeChange,
              isAdmin: isAdmin,
            ),

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

            const SizedBox(height: 20),
            // QR CODE BUTTON
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
    required this.onSelectButtonClicked,
    required this.isAdmin,
  });

  // callback when switch between admin/user login
  final Function(bool isAdmin) onSelectButtonClicked;
  final bool isAdmin;

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
              child: Center(
                child: Text(
                  key: const Key('userTab'),
                  'User',
                  style: TextStyle(
                      color:
                          isAdmin ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onSelectButtonClicked(true),
              child: Center(
                child: Text(
                  key: const Key('adminTab'),
                  'Admin',
                  style: TextStyle(
                      color:
                          isAdmin ? COLOR_TEXT_PRIMARY : COLOR_TEXT_SECONDARY),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimateScrollableLineIndicator extends StatelessWidget {
  const _AnimateScrollableLineIndicator({required this.isAdmin});

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
              key: const Key('studentButton'),
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isStudent
                    ? COLOR_SELECTED_BUTTON_BACKGROUND
                    : COLOR_UNSELECTED_BUTTON_BACKGROUND,
              ),
              child: const Center(child: Text('Student')),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onSelectButtonClicked(false),
            child: Container(
              key: const Key('parentButton'),
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isStudent
                    ? COLOR_UNSELECTED_BUTTON_BACKGROUND
                    : COLOR_SELECTED_BUTTON_BACKGROUND,
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
          key: const Key('userNameField'),
          controller: userNameController,
          placeholder: 'User Name',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          key: const Key('userPasswordField'),
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
          key: const Key('userLoginButton'),
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
          key: const Key('adminEmailField'),
          controller: emailController,
          placeholder: 'Email',
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: CupertinoTextField(
          key: const Key('adminPasswordField'),
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
          key: const Key('adminLoginButton'),
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
