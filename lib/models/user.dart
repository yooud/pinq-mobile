class User {
  User({
    this.username,
    this.displayName,
    this.pictureId,
    this.pictureUrl,
    this.isFriend,
    this.isBlocked,
  });

  String? username;
  String? displayName;
  String? pictureId;
  String? pictureUrl;
  bool? isFriend;
  bool? isBlocked;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      displayName: json['display_name'],
      pictureUrl: json['profile_picture_url'],
    );
  }

  factory User.friendFromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      displayName: json['display_name'],
      pictureUrl: json['profile_picture_url'] ?? 'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg',
      isFriend: json['is_friend'],
      isBlocked: json['is_blocked'],
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
