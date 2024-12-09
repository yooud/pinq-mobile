import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/services/api_service.dart';

class IncomingFriendRequestsProvider extends StateNotifier<List<User>> {
  final Ref ref;

  IncomingFriendRequestsProvider(this.ref) : super([]);

  Future<void> getIncomingFriendRequests() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final friendRequests = await apiService.getIncomingFriendRequests();
      state = friendRequests;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(User user) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.sendFriendRequest(user.username!);
      user.isFriend = true;
      ref.read(friendsProvider.notifier).addFriend(user);
      state = List.from(state)
        ..removeWhere((element) => element.username == user.username);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String username) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.removeFriend(username);
      state = List.from(state)
        ..removeWhere((element) => element.username == username);
    } catch (e) {
      rethrow;
    }
  }
}

final incomingFriendRequestsProvider =
    StateNotifierProvider<IncomingFriendRequestsProvider, List<User>>(
  (ref) => IncomingFriendRequestsProvider(ref),
);
