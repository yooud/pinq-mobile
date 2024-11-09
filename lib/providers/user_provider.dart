import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUserByGoogle(String email) {
      state = User(email: email);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);
