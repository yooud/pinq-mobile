import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/user_provider.dart';

class WSFriendsNotifier extends StateNotifier<List<User>> {
  final Ref ref;
  WSFriendsNotifier(this.ref) : super([]);

  void setFriends(List<dynamic> friends) {
      List<User> allPucksOnMap = friends.map((e) => User.wsFriendFromJson(e)).toList();
      allPucksOnMap.removeWhere(
        (friend) => friend.username == ref.read(userProvider).username);
      state = allPucksOnMap;
  }

  User updateFriendLocation(String username, double lat, double lng) {
    state = [
      for (final friend in state)
        if (friend.username == username)
          friend.copyWith(lat: lat, lng: lng)
        else
          friend
    ];
    return state.firstWhere((friend) => friend.username == username);
  }
}

final wsFriendsProvider = StateNotifierProvider<WSFriendsNotifier, List<User>>(
  (ref) => WSFriendsNotifier(ref),
);
