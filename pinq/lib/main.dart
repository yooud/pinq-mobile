import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinq/screens/authentication.dart';
import 'package:pinq/screens/places.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Color.fromARGB(255, 247, 6, 131),
  background: Color.fromARGB(255, 97, 0, 57),
);

final theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme(
    const TextTheme(
      titleSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.white),
      
    ),
  ),
).copyWith(
  scaffoldBackgroundColor: colorScheme.background,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pinq',
      theme: theme,
      home: const AuthScreen(),
    );
  }
}
