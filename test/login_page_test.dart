import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_flutter/const.dart';
import 'package:login_flutter/login/login_page.dart';
import 'package:login_flutter/util/user_model.dart';
import 'package:provider/provider.dart';

void main() {
  Widget materialAppWrapper(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('test login to admin form with invalid password',
      (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(ChangeNotifierProvider(
      child: const LoginPage(),
      create: (BuildContext context) {
        return UserModel();
      },
    )));

    // select admin tab
    final adminTabFinder = find.byKey(const Key('adminTab'));
    expect(adminTabFinder, findsOneWidget);

    await widgetTester.tap(adminTabFinder);
    await widgetTester.pumpAndSettle();

    // wait for admin form to appear

    final nameFiner = find.byKey(const Key('adminEmailField'));
    final passwordFinder = find.byKey(const Key('adminPasswordField'));
    final loginButtonFinder = find.byKey(const Key('adminLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    // enter valid input
    await widgetTester.enterText(nameFiner, 'test@test.com');
    await widgetTester.enterText(passwordFinder, '1');
    await widgetTester.tap(loginButtonFinder);
    await widgetTester.pump(Durations.extralong4);

    // wait for success toast to appear
    final toastFinder = find.text(TOAST_INVALID_PASSWORD);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets('test login to admin form with invalid email',
      (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    // select admin tab
    final adminTabFinder = find.byKey(const Key('adminTab'));
    expect(adminTabFinder, findsOneWidget);

    await widgetTester.tap(adminTabFinder);
    await widgetTester.pumpAndSettle();

    // wait for admin form to appear

    final nameFiner = find.byKey(const Key('adminEmailField'));
    final passwordFinder = find.byKey(const Key('adminPasswordField'));
    final loginButtonFinder = find.byKey(const Key('adminLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    // enter valid input
    await widgetTester.enterText(nameFiner, 'testtest.com');
    await widgetTester.enterText(passwordFinder, '12345678');
    await widgetTester.tap(loginButtonFinder);
    await widgetTester.pump(Durations.extralong4);

    // wait for success toast to appear
    final toastFinder = find.text(TOAST_INVALID_EMAIL);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets('test login to admin form with validated input',
      (widgetTester) async {
    // await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));
    await widgetTester.pumpWidget(materialAppWrapper(ChangeNotifierProvider(
      child: const LoginPage(),
      create: (BuildContext context) {
        return UserModel();
      },
    )));

    // select admin tab
    final adminTabFinder = find.byKey(const Key('adminTab'));
    expect(adminTabFinder, findsOneWidget);

    await widgetTester.tap(adminTabFinder);
    await widgetTester.pumpAndSettle();

    // wait for admin form to appear

    final nameFiner = find.byKey(const Key('adminEmailField'));
    final passwordFinder = find.byKey(const Key('adminPasswordField'));
    final loginButtonFinder = find.byKey(const Key('adminLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    // enter valid input
    await widgetTester.enterText(nameFiner, 'test@test.com');
    await widgetTester.enterText(passwordFinder, '12345678');
    await widgetTester.tap(loginButtonFinder);
    await widgetTester.pump(Durations.extralong4);

    // wait for success toast to appear
    final toastFinder = find.text(TOAST_SUCCESS_MESSAGE);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets('test login to user form with validated input',
      (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(ChangeNotifierProvider(
      child: const LoginPage(),
      create: (BuildContext context) {
        return UserModel();
      },
    )));

    final nameFiner = find.byKey(const Key('userNameField'));
    final passwordFinder = find.byKey(const Key('userPasswordField'));
    final loginButtonFinder = find.byKey(const Key('userLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    await widgetTester.enterText(nameFiner, 'testtestcom');
    await widgetTester.enterText(passwordFinder, '12345678');
    await widgetTester.tap(loginButtonFinder);
    await widgetTester.pump(Durations.extralong4);

    final toastFinder = find.text(TOAST_SUCCESS_MESSAGE);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets('test login to user form with invalid username',
      (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    final nameFiner = find.byKey(const Key('userNameField'));
    final passwordFinder = find.byKey(const Key('userPasswordField'));
    final loginButtonFinder = find.byKey(const Key('userLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    await widgetTester.enterText(nameFiner, 't');
    await widgetTester.enterText(passwordFinder, '12345678');
    await widgetTester.tap(loginButtonFinder);
    // wait  for snackbar to appear
    await widgetTester.pump(Durations.extralong4);

    final toastFinder = find.text(TOAST_INVALID_USERNAME);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets('test login to user form with invalid password',
      (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    final nameFiner = find.byKey(const Key('userNameField'));
    final passwordFinder = find.byKey(const Key('userPasswordField'));
    final loginButtonFinder = find.byKey(const Key('userLoginButton'));

    expect(nameFiner, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    await widgetTester.enterText(nameFiner, 'testtestcom');
    await widgetTester.enterText(passwordFinder, '1');
    await widgetTester.tap(loginButtonFinder);
    // wait  for snackbar to appear
    await widgetTester.pump(Durations.extralong4);

    final toastFinder = find.text(TOAST_INVALID_PASSWORD);

    expect(toastFinder, findsOneWidget);
  });

  testWidgets("test switch between User and Admin ", (widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    final userTabFinder = find.byKey(const Key('userTab'));
    final adminTabFinder = find.byKey(const Key('adminTab'));

    expect(userTabFinder, findsOneWidget);
    expect(adminTabFinder, findsOneWidget);

    Text userText = widgetTester.widget<Text>(userTabFinder);
    Text adminText = widgetTester.widget<Text>(adminTabFinder);

    // await widgetTester.tap(userTabFinder);
    // await widgetTester.pumpAndSettle();

    expect((userText.style as TextStyle).color, COLOR_TEXT_PRIMARY);
    expect((adminText.style as TextStyle).color, COLOR_TEXT_SECONDARY);

    await widgetTester.tap(adminTabFinder);
    await widgetTester.pumpAndSettle();

    // Re-initialize userText and adminText after state update
    userText = widgetTester.widget<Text>(userTabFinder);
    adminText = widgetTester.widget<Text>(adminTabFinder);

    expect((userText.style as TextStyle).color, COLOR_TEXT_SECONDARY);
    expect((adminText.style as TextStyle).color, COLOR_TEXT_PRIMARY);
  });

  testWidgets(
      'test student and parent button click and switch background color',
      (WidgetTester widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    final studentButtonFinder = find.byKey(const Key('studentButton'));
    final parentButtonFinder = find.byKey(const Key('parentButton'));

    await widgetTester.tap(parentButtonFinder);
    await widgetTester.pump();

    Container studentContainer =
        widgetTester.widget<Container>(studentButtonFinder);

    Container parentContainer =
        widgetTester.widget<Container>(parentButtonFinder);

    expect((studentContainer.decoration as BoxDecoration).color,
        COLOR_UNSELECTED_BUTTON_BACKGROUND);
    expect((parentContainer.decoration as BoxDecoration).color,
        COLOR_SELECTED_BUTTON_BACKGROUND);

    await widgetTester.tap(studentButtonFinder);
    await widgetTester.pump();

    // Re-initialize studentContainer and parentContainer after state update
    studentContainer = widgetTester.widget<Container>(studentButtonFinder);
    parentContainer = widgetTester.widget<Container>(parentButtonFinder);

    expect((studentContainer.decoration as BoxDecoration).color,
        COLOR_SELECTED_BUTTON_BACKGROUND);
    expect((parentContainer.decoration as BoxDecoration).color,
        COLOR_UNSELECTED_BUTTON_BACKGROUND);
  });

  testWidgets('test login form switch initial state',
      (WidgetTester widgetTester) async {
    await widgetTester.pumpWidget(materialAppWrapper(const LoginPage()));

    final studentFinder = find.text('Student');
    final parentFinder = find.text('Parent');

    expect(studentFinder, findsOneWidget);
    expect(parentFinder, findsOneWidget);
  });
}
