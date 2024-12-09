import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/services/api_service.dart';

class OutgoingFriendRequestsProvider extends StateNotifier<List<User>> {
  final Ref ref;

  OutgoingFriendRequestsProvider(this.ref) : super([]);

  Future<void> getOutgoingFriendRequests() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final friendRequests = await apiService.getOutgoingFriendRequests();
      state = friendRequests;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOutgoingFriendRequest(User user) async {
    state = List.from(state)..add(user);
  }

  Future<void> cancelFriendRequest(String username) async {
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

final outgoingFriendRequestsProvider =
    StateNotifierProvider<OutgoingFriendRequestsProvider, List<User>>(
  (ref) => OutgoingFriendRequestsProvider(ref),
);