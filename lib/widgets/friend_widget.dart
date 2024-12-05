import 'package:flutter/material.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/widgets/shiny_button.dart';

class FriendWidget extends StatelessWidget {
  final User friend;
  final bool isFriend;

  const FriendWidget({required this.friend, required this.isFriend, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
            radius: 40,
            backgroundColor: ourPinkColor,
          ),
          IconButton(
            onPressed: () {},
            icon: isFriend
                ? const Icon(Icons.chat_bubble)
                : const Icon(Icons.person_add),
            color: Colors.amber,
            iconSize: 50,
          ),
        ],
      ),
    );
  }
}
