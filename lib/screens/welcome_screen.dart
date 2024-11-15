import 'package:flutter/material.dart';
import 'package:pinq/widgets/shiny_text.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const WelcomeScreen({required this.onFinish, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to the',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ShinyText(
                  text: 'pinq',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 70,
                      ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: onFinish,
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
