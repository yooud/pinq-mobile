import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/widgets/friend_widget.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  String? displayNameError;
  User? searchedUser;
  String enteredUsername = '';

  Widget? friendWidget;
  Widget? friendRequestsWidget;
  Widget? userSearchWidget;

  void _validateUsername(BuildContext context) async {
    try {
      User userResult = await ref
          .read(friendsProvider.notifier)
          .getUserByUsername(enteredUsername);
      FocusScope.of(context).unfocus();
      setState(() {
        searchedUser = userResult;
      });
      displayNameError = null;
    } catch (e) {
      setState(
        () {
          displayNameError = e.toString();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    List<User> friends = ref.watch(friendsProvider);

    friendWidget = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return FriendWidget(
          friend: friends[index],
        );
      },
    );

    if (searchedUser != null) {
      userSearchWidget = FriendWidget(
        friend: searchedUser!,
      );
    }

    Future<void> onShowFriendRequests() async {
      try {
        List<User> friendRequests =
            await ref.read(friendsProvider.notifier).getFriendRequests();
        setState(() {
          friendRequestsWidget = ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              return FriendWidget(
                friend: friendRequests[index],
              );
            },
          );
        });
      } catch (e) {
        setState(() {
          displayNameError = e.toString();
        });
      }
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, keyboardSpace + 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (String s) {
                          enteredUsername = s;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter a username',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontSize: 20),
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ourPinkColor),
                          ),
                          errorText: displayNameError,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        _validateUsername(context);
                      },
                      icon: const Icon(Icons.search),
                      iconSize: 35,
                      color: ourPinkColor,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: friendRequestsWidget == null
                          ? () async {
                              await onShowFriendRequests();
                            }
                          : () async {
                              setState(() {
                                friendRequestsWidget = null;
                              });
                            },
                      icon: friendRequestsWidget == null
                          ? const Icon(Icons.person_add)
                          : const Icon(Icons.arrow_back_ios_new_rounded),
                      iconSize: 35,
                      color: ourPinkColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (userSearchWidget != null) userSearchWidget!,
              if (friendRequestsWidget != null) friendRequestsWidget!,
              if (userSearchWidget == null && friendRequestsWidget == null)
                friendWidget!,
            ],
          ),
        ),
      );
    });
  }
}
