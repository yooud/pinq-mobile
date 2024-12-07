import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/widgets/shiny_button.dart';

class FriendWidget extends ConsumerStatefulWidget {
  final User friend;
  final bool isFriend;

  const FriendWidget({
    required this.friend,
    required this.isFriend,
    super.key,
  });

  @override
  ConsumerState<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends ConsumerState<FriendWidget> {
  bool isPending = false;

  Future<void> _onAddFriend() async {
    try {
      String status = await ref
          .read(friendsProvider.notifier)
          .sendFriendRequest(widget.friend.username!);
      if (status == 'pending') {
        setState(() {
          isPending = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width *
                0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.displayName!,
                  style: const TextStyle(fontSize: 30),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                ShinyButton(
                  onPressed: () {},
                  text: widget.friend.username!,
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
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.friend.pictureUrl!),
            radius: 40,
            backgroundColor: ourPinkColor,
          ),
          IconButton(
            onPressed: isPending
                ? () {}
                : widget.isFriend
                    ? () {}
                    : _onAddFriend,
            icon: isPending
                ? const Icon(Icons.check)
                : widget.isFriend
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
