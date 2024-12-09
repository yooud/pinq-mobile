import 'package:flutter/material.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/screens/friend_settings_screen.dart';
import 'package:pinq/widgets/shiny_text.dart';

class FriendWidget extends StatefulWidget {
  final User friend;
  final String? requestType;
  final void Function()? onAcceptFriendRequest;
  final void Function()? onRejectFriendRequest;
  final void Function()? onCancelFriendRequest;
  final void Function()? onRemoveFriend;
  final void Function()? onAddFriend;

  const FriendWidget({
    required this.friend,
    this.onRemoveFriend,
    this.onAddFriend,
    this.requestType,
    this.onAcceptFriendRequest,
    this.onRejectFriendRequest,
    this.onCancelFriendRequest,
    super.key,
  });

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool isRequestSendedToSearchedUser = false;

  void _openFriendSettingsOverlay() async {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => FriendSettingsScreen(
        friend: widget.friend,
        onRemoveFriend: widget.onRemoveFriend!,
      ),
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
              if (widget.friend.isFriend!)
                IconButton(
                  onPressed: _openFriendSettingsOverlay,
                  icon: const Icon(Icons.keyboard_control),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
              if (widget.requestType == null &&
                  !widget.friend.isFriend! &&
                  !isRequestSendedToSearchedUser)
                IconButton(
                  onPressed: () {
                    widget.onAddFriend!();
                    setState(() {
                      isRequestSendedToSearchedUser = true;
                    });
                  },
                  icon: const Icon(Icons.person_add),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
              if (widget.requestType == null &&
                  !widget.friend.isFriend! &&
                  isRequestSendedToSearchedUser)
                IconButton(
                  onPressed: () {
                    widget.onCancelFriendRequest!();
                    setState(() {
                      isRequestSendedToSearchedUser = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: ourPinkColor,
                  iconSize: 30,
                ),
              if (widget.requestType != null &&
                  widget.requestType == 'incoming')
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onAcceptFriendRequest,
                      icon: const Icon(Icons.person_add),
                      color: ourPinkColor,
                      iconSize: 30,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: widget.onRejectFriendRequest,
                      icon: const Icon(Icons.close_rounded),
                      color: ourPinkColor,
                      iconSize: 30,
                    ),
                  ],
                ),
              if (widget.requestType != null &&
                  widget.requestType == 'outgoing')
                IconButton(
                  onPressed: widget.onCancelFriendRequest,
                  icon: const Icon(Icons.close_rounded),
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
