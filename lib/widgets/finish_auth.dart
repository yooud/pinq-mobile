import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/models/validation_exception.dart';
import 'package:pinq/providers/user_provider.dart';
import 'package:pinq/widgets/shiny_button.dart';

class FinishAuth extends ConsumerStatefulWidget {
  const FinishAuth({super.key});

  @override
  ConsumerState<FinishAuth> createState() => _FinishAuthState();
}

class _FinishAuthState extends ConsumerState<FinishAuth> {
  final PageController _pageController = PageController();
  String displayName = '';
  String username = '';
  String? displayNameError;
  String? usernameError;

  void _nextPage() {
    if (displayNameError == null && usernameError == null) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _complete() async {
    try {
      await ref.read(userProvider.notifier).completeRegistration(
            User(
              username: username,
              displayName: displayName,
            ),
          );
    } on ValidationException catch (e) {
      print(e.errors['Username']);
      print(e.errors['DisplayName']);
    } catch (e) {
      print('Error: $e');
    }

    Navigator.of(context).pop();
  }

  void _validateDisplayName(String value) {
    setState(() {
      displayName = value;
      if (value.length < 5 || value.length > 20) {
        displayNameError = 'Name must be between 5 and 20 characters';
      } else {
        displayNameError = null;
      }
    });
  }

  void _validateUsername(String value) {
    setState(() {
      username = value;
      if (value.length < 5 || value.length > 20) {
        usernameError = 'Username must be between 5 and 20 characters';
      } else {
        usernameError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ourDarkColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Just a few steps left...",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                ShinyButton(
                  onPressed: _nextPage,
                  text: "Lets start",
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Think up a name that will be shown to other users",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: _validateDisplayName,
                  decoration: InputDecoration(
                    hintText: 'Name',
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Come up with the username",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: _validateUsername,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(fontSize: 20),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ourPinkColor),
                    ),
                    errorText: usernameError,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _complete();
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
