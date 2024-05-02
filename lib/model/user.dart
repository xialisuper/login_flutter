class User {
  // user name
  String name;

  // if a user has a token, it means he is logged in.
  // otherwise, it means he is not logged in, has to login first.
  String token;

  UserType type;

  //TODO: user avatar

  User({
    required this.name,
    required this.token,
    required this.type,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'type': type.index,
    };
  }

  // to string
  @override
  String toString() {
    return 'User(name: $name, token: $token, type: $type)';
  }
}

enum UserType { student, parent, admin }
