class Validations {
  // Function to validate a username.
  // Username should be 3 to 20 characters long 
  static bool isValidatedUserName(String userName) {
    // RegExp regex = RegExp(
    //     r'^[a-zA-Z0-9_]{3,20}$'); // Regular expression for username validation
    // return regex.hasMatch(userName);
    return userName.length >= 3 && userName.length <= 20;
  }

  // Function to validate a email.
  // Email should match standard email format i.e., string@string.string
  static bool isValidatedEmail(String email) {
    RegExp regex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Regular expression for email validation
    return regex.hasMatch(email);
  }

  // Function to validate a password.
  // Password should be at least 8 characters long 
  static bool isValidatedPassword(String password) {
    // RegExp regex = RegExp(
    //     r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$'); // Regular expression for password validation
    // return regex.hasMatch(password);

    return password.length >= 8;
  }
}
