import 'package:flutter/material.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';

class FriendSettingsScreen extends StatefulWidget {
  const FriendSettingsScreen({
    required this.friend,
    required this.onRemoveFriend,
    required this.onMoveToFriend,
    super.key,
  });
  final User friend;
  final void Function() onRemoveFriend;
  final void Function() onMoveToFriend;

  @override
  State<FriendSettingsScreen> createState() => _FriendSettingsScreenState();
}

class _FriendSettingsScreenState extends State<FriendSettingsScreen> {
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
                    onPressed: 
                      widget.onRemoveFriend
                    ,
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Move to friend',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onRemoveFriend();
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
