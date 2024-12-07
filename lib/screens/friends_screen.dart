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
  List<User> friends = [];
  User? searchedUser;
  String enteredUsername = '';

  bool isCheckingFriendRequests = false;

  Widget? friendWidget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    friends = ref.watch(friendsProvider);

    _onShowFriends();
  }

  void _onShowFriends() {
    setState(() {
      friendWidget = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return FriendWidget(
            friend: friends[index],
            isFriend: friends[index].isFriend!,
          );
        },
      );
    });
  }

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

  Future<void> _onShowFriendRequests() async {
    try {
      List<User> friendRequests =
          await ref.read(friendsProvider.notifier).getFriendRequests();
      setState(() {
        friendWidget = ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            return FriendWidget(
              friend: friendRequests[index],
              isFriend: false,
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

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    if (searchedUser != null) {
      friendWidget = FriendWidget(
        friend: searchedUser!,
        isFriend: searchedUser!.isFriend!,
      );
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardSpace + 20),
          child: Column(
            children: [
              Row(
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
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: isCheckingFriendRequests
                        ? () {
                            setState(() {
                              isCheckingFriendRequests = false;
                            });
                            _onShowFriends();
                          }
                        : () async {
                            setState(() {
                              isCheckingFriendRequests = true;
                            });
                            await _onShowFriendRequests();
                          },
                    icon: isCheckingFriendRequests
                        ? const Icon(Icons.arrow_back_ios_new_rounded)
                        : const Icon(Icons.person_add),
                    iconSize: 35,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              friendWidget!,
            ],
          ),
        ),
      );
    });
  }
}
