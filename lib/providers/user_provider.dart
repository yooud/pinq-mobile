import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUserByGoogle(String email, String logoUrl) {
    state = User(email: email, logoUrl: logoUrl);
  }

  void setUserFinalData(String displayName, String username) {
    state!.displayName = displayName;
    state!.username = username;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);
