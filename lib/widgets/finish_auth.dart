import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
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

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _complete() {
    Navigator.of(context).pop();
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
                  onChanged: (value) => displayName = value,
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
                  onChanged: (value) => username = value,
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
