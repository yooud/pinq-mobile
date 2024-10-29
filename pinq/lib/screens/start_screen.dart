import 'package:flutter/material.dart';
import 'package:pinq/screens/auth.dart';
import 'package:pinq/widgets/main_drawer.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pinq'),
      ),
      body: const Center(
        child: Text('Logged in!'),
      ),
      drawer: HamburgerMenu(
        onSelectScreen: (identifier) {},
      ),
    );
  }
}
