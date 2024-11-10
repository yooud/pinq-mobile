class User {
  User({
    this.email,
    this.username,
    this.displayName,
    this.logoUrl,
  });

  String? email;
  String? username;
  String? displayName;
  String? logoUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'logoUrl': logoUrl,
    };
  }
}
