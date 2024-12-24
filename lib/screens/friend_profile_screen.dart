import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/providers/ws_friends_provider.dart';

import 'package:pinq/widgets/shiny_button.dart';

class FriendProfileScreen extends ConsumerWidget {
  const FriendProfileScreen({required this.friendId, super.key});
  final int friendId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friend = ref
        .read(wsFriendsProvider)
        .where((friend) => friend.id == friendId)
        .first;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName!,
                      style: const TextStyle(fontSize: 30),
                    ),
                    ShinyButton(
                      onPressed: () {},
                      text: friend.username!,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ourPinkColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                      ),
                      colors: [
                        ourDarkColor,
                        Colors.white,
                        ourDarkColor,
                      ],
                    )
                  ],
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(friend.pictureUrl!),
                  radius: 50,
                  backgroundColor: ourPinkColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
