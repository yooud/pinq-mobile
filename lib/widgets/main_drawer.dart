import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({
    super.key,
    required this.onSelectScreen,
  });
  final void Function(String identifier) onSelectScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 0, 115),
                  Color.fromARGB(255, 255, 74, 210),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://yt3.googleusercontent.com/ytc/AIdro_mT2QBvRmDHkeee7q4LPluCswzD7VB0yWvDwzjm8XHCsA=s900-c-k-c0x00ffffff-no-rj'),
                radius: 40,
              ),
              const SizedBox(width: 18),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'displayed name',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '@login',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ]),
          ),
          ListTile(
            leading: const Icon(
              Icons.list_alt_outlined,
              size: 26,
              color: Color(0xFFB28ECC),
            ),
            title: Text(
              'Feed',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: const Color(0xFFB28ECC),
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              onSelectScreen('feed');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              size: 26,
              color: Color(0xFFB28ECC),
            ),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: const Color(0xFFB28ECC),
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              onSelectScreen('settings');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: 26,
              color: Color(0xFFB28ECC),
            ),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: const Color(0xFFB28ECC),
                    fontSize: 24,
                  ),
            ),
            onTap: () async {
              await GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
