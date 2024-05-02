class User {
  // user name
  String name;
  String email;

  // if a user has a token, it means he is logged in.
  // otherwise, it means he is not logged in, has to login first.
  String token;

  UserType type;

  String avatarPath;

  User({
    required this.name,
    required this.token,
    required this.type,
    required this.avatarPath,
    required this.email,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'type': type.index,
      'avatarPath': avatarPath,
      'email': email,
    };
  }

  // to string
  @override
  String toString() {
    return 'User(name: $name, token: $token, type: $type, avatarPath: $avatarPath), email: $email';
  }
}

enum UserType { student, parent, admin }
