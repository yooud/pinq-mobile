import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinq/models/our_colors.dart';
import 'package:pinq/screens/auth_screen.dart';
import 'package:pinq/screens/splash_screen.dart';
import 'package:pinq/screens/start_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pinq/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: ourPinkColor,
  onSurface: Colors.white,
  surface: ourDarkColor,
);

final theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
).copyWith(
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
  await dotenv.load(fileName: '.env');
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isFirstLaunch') ?? true) {
      await prefs.setBool('isFirstLaunch', false);
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pinq',
      theme: theme,
      home: FutureBuilder<bool>(
        future: _isFirstLaunch(),
        builder: (context, firstLaunchSnapshot) {
          if (firstLaunchSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (firstLaunchSnapshot.data == true) {
            return WelcomeScreen(
              onFinish: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthOrStartScreen(),
                  ),
                );
              },
            );
          }

          return const AuthOrStartScreen();
        },
      ),
    );
  }
}

class AuthOrStartScreen extends StatelessWidget {
  const AuthOrStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
    );
  }
}
