import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/providers/user_provider.dart';
import 'package:pinq/services/api_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: await _showReauthenticateDialog(),
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.providerData.any((p) => p.providerId == 'password')) {
      try {
        await _reauthenticateUser();
        String newPassword = await _showChangePasswordDialog();
        if (newPassword.isNotEmpty) {
          if (newPassword.length >= 8) {
            await user.updatePassword(newPassword);

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );
          } else {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Password must be at least 8 characters long')),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      }
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot change password for Google account')),
      );
    }
  }

  Future<void> _changeDisplayName() async {
    String newDisplayName = await _showChangeDisplayNameDialog();
    if (newDisplayName.isNotEmpty) {
      try {
        await ref
            .read(userProvider.notifier)
            .updateUserDisplayName(newDisplayName);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name changed successfully')),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _changeUsername() async {
    String newUsername = await _showChangeUsernameDialog();
    if (newUsername.isNotEmpty) {
      try {
        await ref.read(userProvider.notifier).updateUserUsername(newUsername);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username changed successfully')),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<String> _showChangePasswordDialog() async {
    String newPassword = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontSize: 20),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ourPinkColor),
              ),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
    return newPassword.trim();
  }

  Future<String> _showChangeDisplayNameDialog() async {
    String newDisplayName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change name'),
          content: TextField(
            onChanged: (value) {
              newDisplayName = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter new name',
              hintStyle: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontSize: 20),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ourPinkColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
    return newDisplayName.trim();
  }

  Future<String> _showChangeUsernameDialog() async {
    String newUsername = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter new username',
              hintStyle: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontSize: 20),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ourPinkColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
    return newUsername.trim();
  }

  Future<String> _showReauthenticateDialog() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reauthenticate'),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter your current password',
              hintStyle: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontSize: 20),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ourPinkColor),
              ),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Reauthenticate'),
            ),
          ],
        );
      },
    );
    return password.trim();
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
                  child: ElevatedButton(
                    onPressed: () async {
                      await _changeDisplayName();
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Change Name',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _changeUsername();
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Change Username',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _changePassword();
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref.read(apiServiceProvider).logOut();
                      ref.read(userProvider.notifier).clearUser();
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: ourDarkColor,
                    ),
                    child: Text(
                      'Exit an account',
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
