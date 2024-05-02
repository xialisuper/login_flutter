class User {
  // user name
  String name;

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
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'type': type.index,
      'avatarPath': avatarPath,
    };
  }

  // to string
  @override
  String toString() {
    return 'User(name: $name, token: $token, type: $type, avatarPath: $avatarPath)';
  }
}

enum UserType { student, parent, admin }
