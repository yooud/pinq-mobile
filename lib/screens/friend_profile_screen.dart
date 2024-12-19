import 'package:flutter/material.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';

import 'package:pinq/widgets/shiny_button.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({required this.friend, super.key});
  final User friend;

  @override
  Widget build(BuildContext context) {
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
                  backgroundImage:
                      NetworkImage(friend.pictureUrl!),
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
