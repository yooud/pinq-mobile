import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';

class FriendSettingsScreen extends ConsumerStatefulWidget {
  const FriendSettingsScreen({required this.friend, super.key});
  final User friend;

  @override
  ConsumerState<FriendSettingsScreen> createState() =>
      _FriendSettingsScreenState();
}

class _FriendSettingsScreenState extends ConsumerState<FriendSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              widget.friend.username!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(friendsProvider.notifier).removeFriend(widget.friend.username!);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Delete friend',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
