import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/providers/user_provider.dart';
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
  String username = '';

  @override
  void initState() {
    super.initState();

    friends = ref.read(friendsProvider);
  }

  void _validateUsername(BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      User userResult =
          await ref.read(friendsProvider.notifier).getUserByUsername(username);
      setState(() {
        searchedUser = userResult;
      });
      displayNameError = null;
    } catch (e) {
      displayNameError = e.toString();
    }
  }

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
                Expanded(
                  child: TextField(
                    onChanged: (String s) {
                      username = s;
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
                )
              ],
            ),
            const SizedBox(height: 20),
            searchedUser == null
                // ? ListView.builder(
                //     shrinkWrap: true,
                //     physics: const NeverScrollableScrollPhysics(),
                //     itemCount: friends.length,
                //     itemBuilder: (context, index) {
                //       return FriendWidget(
                //           friend: friends[index],
                //           isFriend: friends[index].isFriend!);
                //     },
                //   )
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return FriendWidget(
                          friend: ref.read(userProvider), isFriend: true);
                    },
                  )
                : FriendWidget(
                    friend: searchedUser!, isFriend: searchedUser!.isFriend!),
          ],
        ),
      ),
    );
  }
}
