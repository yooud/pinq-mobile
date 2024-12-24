import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/user_provider.dart';

class WSFriendsNotifier extends StateNotifier<List<User>> {
  final Ref ref;
  WSFriendsNotifier(this.ref) : super([]);

  Future<void> setFriends(List<dynamic> friends) async{
    List<User> allPucksOnMap =
        friends.map((e) => User.wsFriendFromJson(e)).toList();
    if (allPucksOnMap.isNotEmpty) {
      int userId = allPucksOnMap[allPucksOnMap.length - 1].id!;
      ref.read(userProvider).id = userId;
      allPucksOnMap.removeAt(allPucksOnMap.length - 1);
    }
    state = allPucksOnMap;
  }

  User updateFriendLocation(int id, double lat, double lng) {
    state = [
      for (final friend in state)
        if (friend.id == id) friend.copyWith(lat: lat, lng: lng) else friend
    ];
    return state.firstWhere((friend) => friend.id == id);
  }

  void removeFriend(int id) {
    state = [...state.where((friend) => friend.id != id)];
  }

  void addFriend(User friend) {
    state = [...state, friend];
  }
}

final wsFriendsProvider = StateNotifierProvider<WSFriendsNotifier, List<User>>(
  (ref) => WSFriendsNotifier(ref),
);
