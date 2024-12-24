import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/screens/friend_profile_screen.dart';
import 'package:pinq/screens/profile_screen.dart';

class AnnotationListener implements OnPointAnnotationClickListener {
  AnnotationListener(
      {required this.annotationFriendMap,
      required this.user,
      required this.context});

  final Map<String, int> annotationFriendMap;
  final User user;
  final BuildContext context;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final friendId = annotationFriendMap[annotation.id];

    if (friendId == null) {
      return;
    }

    if (friendId == user.id) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        builder: (ctx) => const ProfileScreen(),
      );
      return;
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => FriendProfileScreen(friendId: friendId),
    );
  }
}
