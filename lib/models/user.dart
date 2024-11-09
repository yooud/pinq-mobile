class User {
  User({
    required this.email,
    this.username,
    this.displayName,
    this.logoUrl,
  });

  final String email;
  String? username;
  String? displayName;
  String? logoUrl;
}
