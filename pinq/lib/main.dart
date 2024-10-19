import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinq/screens/places.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 102, 6, 247),
  background: const Color.fromARGB(255, 56, 49, 66),
);

final theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme(
    const TextTheme(
      titleSmall: TextStyle(fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
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
      title: 'Great Places',
      theme: theme,
      home: const PlacesScreen(),
    );
  }
}
