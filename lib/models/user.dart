class User {
  User({
    this.username,
    this.displayName,
    this.pictureId,
    this.pictureUrl,
  });

  String? username;
  String? displayName;
  String? pictureId;
  String? pictureUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      displayName: json['display_name'],
      pictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
      'picture_id': pictureId,
    };
  }

    User copyWith({
    String? username,
    String? displayName,
    String? pictureId,
    String? pictureUrl,
  }) {
    return User(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      pictureId: pictureId ?? this.pictureId,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }
}
