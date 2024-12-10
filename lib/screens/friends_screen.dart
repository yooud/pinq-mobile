import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/providers/incoming_provider.dart';
import 'package:pinq/providers/outgoing_provider.dart';
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
  int selectedButtonIndex = 0;

  Widget? friendsWidget;
  Widget? incomingFriendRequestsWidget;
  Widget? outgoingFriendRequestsWidget;
  Widget? userSearchWidget;

  void _validateUsername(BuildContext context) async {
    setState(
      () {
        selectedButtonIndex = -1;
      },
    );
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
    List<User> incomingFriendRequests =
        ref.watch(incomingFriendRequestsProvider);
    List<User> outgoingFriendRequests =
        ref.watch(outgoingFriendRequestsProvider);

    friendsWidget = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return FriendWidget(
            friend: friends[index],
            onRemoveFriend: () {
              try {
                ref
                    .read(friendsProvider.notifier)
                    .removeFriend(friends[index].username!);
              } catch (e) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            });
      },
    );

    incomingFriendRequestsWidget = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomingFriendRequests.length,
      itemBuilder: (context, index) {
        return FriendWidget(
          friend: incomingFriendRequests[index],
          requestType: 'incoming',
          onAcceptFriendRequest: () {
            ref
                .read(incomingFriendRequestsProvider.notifier)
                .acceptFriendRequest(
                  incomingFriendRequests[index],
                );
          },
          onRejectFriendRequest: () {
            ref
                .read(incomingFriendRequestsProvider.notifier)
                .rejectFriendRequest(
                  incomingFriendRequests[index].username!,
                );
          },
        );
      },
    );

    outgoingFriendRequestsWidget = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outgoingFriendRequests.length,
      itemBuilder: (context, index) {
        return FriendWidget(
          friend: outgoingFriendRequests[index],
          requestType: 'outgoing',
          onCancelFriendRequest: () {
            try {
              ref
                  .read(outgoingFriendRequestsProvider.notifier)
                  .cancelFriendRequest(
                    outgoingFriendRequests[index].username!,
                  );
            } catch (e) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        );
      },
    );

    if (searchedUser != null) {
      userSearchWidget = FriendWidget(
        friend: searchedUser!,
        onAddFriend: () {
          try {
            ref.read(friendsProvider.notifier).sendFriendRequest(searchedUser!);
          } catch (e) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
        onCancelFriendRequest: () {
          try {
            ref
                .read(outgoingFriendRequestsProvider.notifier)
                .cancelFriendRequest(
                  searchedUser!.username!,
                );
          } catch (e) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
      );
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          displayNameError = null;
                          selectedButtonIndex = 0;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin,
                            size: 30,
                            color: selectedButtonIndex == 0
                                ? ourPinkColor
                                : Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Friends',
                            style: TextStyle(
                              fontSize: 18,
                              color: selectedButtonIndex == 0
                                  ? ourPinkColor
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          selectedButtonIndex = 1;
                          displayNameError = null;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            size: 30,
                            color: selectedButtonIndex == 1
                                ? ourPinkColor
                                : Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Incoming',
                            style: TextStyle(
                              fontSize: 18,
                              color: selectedButtonIndex == 1
                                  ? ourPinkColor
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          selectedButtonIndex = 2;
                          displayNameError = null;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 30,
                            color: selectedButtonIndex == 2
                                ? ourPinkColor
                                : Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Outgoing',
                            style: TextStyle(
                              fontSize: 18,
                              color: selectedButtonIndex == 2
                                  ? ourPinkColor
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (userSearchWidget != null && selectedButtonIndex == -1)
                userSearchWidget!,
              if (selectedButtonIndex == 0) friendsWidget!,
              if (selectedButtonIndex == 1) incomingFriendRequestsWidget!,
              if (selectedButtonIndex == 2) outgoingFriendRequestsWidget!,
            ],
          ),
        ),
      );
    });
  }
}
