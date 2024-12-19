import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/screens/friend_profile_screen.dart';

class AnnotationListener implements OnPointAnnotationClickListener {
   AnnotationListener({required this.annotationFriendMap, required this.context});

  final Map<String, User> annotationFriendMap;
  final BuildContext context;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final friend = annotationFriendMap[annotation.id];

if (friend != null) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        builder: (ctx) => FriendProfileScreen(friend: friend),
      );
    }
  }
}
