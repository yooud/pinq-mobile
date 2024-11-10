import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/services/api_service.dart';

class UserNotifier extends StateNotifier<User?> {
  final Ref ref;

  UserNotifier(this.ref) : super(null);

  Future<void> initializeUser() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.initializeTokens();

      final userData = await apiService.getUserData();
      state = userData as User?;
    } catch (e) {
      print(e.toString());
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(ref),
);
