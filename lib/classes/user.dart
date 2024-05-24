class User {
  final String username;
  final String email;

  User({required this.username, required this.email});

  User copyWith({String? username, String? email}) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
