import 'package:flutter_test/flutter_test.dart';
import 'package:login_flutter/util/validations.dart';

void main() {
  // Testing the isValidatedUserName function.
  test('test if username validation function is working as expected', () {
    expect(Validations.isValidatedUserName("Emily2021"), true);
    expect(Validations.isValidatedUserName("Em"), false);
    expect(
        Validations.isValidatedUserName(
            "Emily_2021_username_length_more_than_20_characters"),
        false);
    expect(Validations.isValidatedUserName(""), false);
  });

  // Testing the isValidatedEmail function.
  test('test if email validation function is working as expected', () {
    expect(Validations.isValidatedEmail("emily2021@gmail.com"), true);
    expect(Validations.isValidatedEmail("emily2021_gmail.com"), false);
    expect(Validations.isValidatedEmail("emily2021@gmailcom"), false);
    expect(Validations.isValidatedUserName(""), false);
  });

  // Testing the isValidatedPassword function.
  test('test if password validation function is working as expected', () {
    expect(Validations.isValidatedPassword("Emily@2021"), true);
    expect(Validations.isValidatedPassword("Emily2021"), false);
    expect(Validations.isValidatedPassword("Emily@"), false);
    expect(Validations.isValidatedPassword("e@2"), false);
    expect(Validations.isValidatedUserName(""), false);
  });
}
