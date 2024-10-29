import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinq/screens/auth.dart';
import 'package:pinq/screens/splash.dart';
import 'package:pinq/screens/start_screen.dart';
import 'package:pinq/screens/places.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Color.fromARGB(255, 247, 6, 131),
  background: Color.fromARGB(255, 97, 0, 57),
);

final theme = ThemeData.from(
  colorScheme: colorScheme.copyWith(
    onSurface: Colors.white,
  ),
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
).copyWith(
  scaffoldBackgroundColor: colorScheme.background,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pinq',
      theme: theme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const StartScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
