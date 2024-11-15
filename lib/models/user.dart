class User {
  User({
    this.username,
    this.displayName,
    this.logoUrl,
  });

  String? username;
  String? displayName;
  String? logoUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      displayName: json['display_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
    };
  }
}
