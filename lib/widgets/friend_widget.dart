import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/screens/friend_settings_screen.dart';
import 'package:pinq/widgets/shiny_text.dart';

class FriendWidget extends ConsumerStatefulWidget {
  final User friend;

  const FriendWidget({
    required this.friend,
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

  void _openFriendSettingsOverlay() async {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => FriendSettingsScreen(friend: widget.friend),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.friend.pictureUrl!),
                      radius: 30,
                      backgroundColor: ourPinkColor,
                    ),
                    const SizedBox(width: 20),
                    ShinyText(
                      text: widget.friend.displayName!,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 25,
                          ),
                      colors: [
                        ourPinkColor,
                        const Color.fromARGB(255, 255, 72, 133),
                        ourPinkColor,
                      ],
                      reverseAnimation: true,
                    ),
                  ],
                ),
              ),
              if (!widget.friend.isFriend! && isPending)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
              if (!widget.friend.isFriend! && !isPending)
                IconButton(
                  onPressed: _onAddFriend,
                  icon: const Icon(Icons.person_add),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
              if (widget.friend.isFriend!)
                IconButton(
                  onPressed: _openFriendSettingsOverlay,
                  icon: const Icon(Icons.keyboard_control),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
