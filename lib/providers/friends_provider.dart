import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/services/api_service.dart';

class FriendsNotifier extends StateNotifier<List<User>> {
  final Ref ref;

  FriendsNotifier(this.ref) : super([]);

  Future<void> fetchFriends() async {
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
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<User>>(
  (ref) => FriendsNotifier(ref),
);
