class User {
  String name;
  String email;
  int userID;

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
    required this.userID,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'type': type.index,
      'avatarPath': avatarPath,
      'email': email,
      'userID': userID
    };
  }

  // from map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      token: map['token'] ?? '',
      type: UserType.values[map['type']],
      avatarPath: map['avatarPath'] ?? '',
      email: map['email'] ?? '',
      userID: map['userID'] ?? -1,
    );
  }

  // to string
  @override
  String toString() {
    return 'User(name: $name, token: $token, type: $type, avatarPath: $avatarPath), email: $email, userID: $userID)';
  }
}

enum UserType { student, parent, admin }
