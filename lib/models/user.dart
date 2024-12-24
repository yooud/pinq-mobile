class User {
  User({
    this.id,
    this.username,
    this.displayName,
    this.pictureId,
    this.pictureUrl,
    this.isFriend,
    this.isBlocked,
    this.lastActivity,
    this.lng,
    this.lat,
  });

  int? id;
  String? username;
  String? displayName;
  String? pictureId;
  String? pictureUrl;
  bool? isFriend;
  bool? isBlocked;
  int? lastActivity;
  double? lng;
  double? lat;

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
      pictureUrl: json['profile_picture_url'] ??
          'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg',
      isFriend: json['is_friend'],
      isBlocked: json['is_blocked'],
    );
  }
  factory User.wsFriendFromJson(Map<String, dynamic> json) {
    double? lng;
    double? lat;
    if (json['location'] != null) {
      Map<String, dynamic> locationJson = json['location'];
      lng = locationJson['lng'].toDouble();
      lat = locationJson['lat'].toDouble();
    } else {
      lng = null;
      lat = null;
    }

    return User(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      pictureUrl: json['profile_picture_url'] ??
          'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg',
      lastActivity: json['last_activity'],
      lng: lng,
      lat: lat,
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
    int? id,
    String? username,
    String? displayName,
    String? pictureId,
    String? pictureUrl,
    double? lng,
    double? lat,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      pictureId: pictureId ?? this.pictureId,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
    );
  }
}
