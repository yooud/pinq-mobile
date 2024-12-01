import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pinq/models/invalid_exception.dart';
import 'package:pinq/models/null_exception.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/services/api_service.dart';

class UserNotifier extends StateNotifier<User> {
  final Ref ref;

  UserNotifier(this.ref) : super(User());

  Future<void> initializeUser() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final userData = await apiService.getUserData();
      userData.pictureUrl ??=
          'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg';
      state = userData;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> isRegistraionCompleted() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.initializeTokens();
      return await apiService.getSessionStatus();
    } on NullSessionTokenException {
      await apiService.initializeSessionToken();
      return await apiService.getSessionStatus();
    } on InvalidSessionTokenException {
      await GoogleSignIn().signOut();
      await fire.FirebaseAuth.instance.signOut();
      rethrow;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> completeRegistration(User user) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.updateUserProfile(user);
      String? photoUrl = fire.FirebaseAuth.instance.currentUser!.photoURL;
      if (photoUrl != null) {
        String pictureId =
            await ref.read(apiServiceProvider).uploadProfileImage(photoUrl);
        user.pictureId = pictureId;
      }
      await apiService.updateUserPicture(user);
      state = user;
    } catch (e) {
      print(e.toString());
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(ref),
);
