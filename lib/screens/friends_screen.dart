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

  Future<void> _validateUsername(BuildContext context) async {
    try {
      User userResult = await ref
          .read(friendsProvider.notifier)
          .getUserByUsername(enteredUsername);
      FocusScope.of(context).unfocus();
      setState(() {
        searchedUser = userResult;
        displayNameError = null;
      });
    } catch (e) {
      setState(() {
        displayNameError = e.toString();
      });
    }
  }

  Future<List<User>> _getFriendRequests() async {
    try {
      return await ref.read(friendsProvider.notifier).getFriendRequests();
    } catch (e) {
      setState(() {
        displayNameError = e.toString();
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    List<User> friends = ref.watch(friendsProvider);

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
                        onChanged: (String s) => enteredUsername = s,
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
                      onPressed: () => _validateUsername(context),
                      icon: const Icon(Icons.search),
                      iconSize: 30,
                      color: ourPinkColor,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () async {
                        final requests = await _getFriendRequests();
                        if (requests.isEmpty) {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'No friend requests',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                          );
                          return;
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SizedBox(
                            height: MediaQuery.of(ctx).size.height * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  return FriendWidget(friend: requests[index]);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      iconSize: 30,
                      color: ourPinkColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (searchedUser != null) FriendWidget(friend: searchedUser!),
              if (searchedUser == null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return FriendWidget(friend: friends[index]);
                  },
                ),
            ],
          ),
        ),
      );
    });
  }
}
