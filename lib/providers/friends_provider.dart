import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/outgoing_provider.dart';
import 'package:pinq/services/api_service.dart';

class FriendsNotifier extends StateNotifier<List<User>> {
  final Ref ref;

  FriendsNotifier(this.ref) : super([]);

  Future<void> getFriends() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final friends = await apiService.getFriends();
      state = friends;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserByUsername(String username) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      return await apiService.getUserByUsername(username);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendFriendRequest(User user) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.sendFriendRequest(user.username!);
      ref
          .read(outgoingFriendRequestsProvider.notifier)
          .addOutgoingFriendRequest(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFriend(String username) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.removeFriend(username);
      state = List.from(state)
        ..removeWhere((element) => element.username == username);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFriend(User user) async {
    state = List.from(state)..add(user);
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<User>>(
  (ref) => FriendsNotifier(ref),
);
