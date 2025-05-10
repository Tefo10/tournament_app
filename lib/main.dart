import 'package:flutter/material.dart';
import 'pages/tournament_home_page.dart';

void main() {
  runApp(const TournamentApp());
}

class TournamentApp extends StatelessWidget {
  const TournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creador de Torneos',
      theme: _epicDarkTheme,
      home: const TournamentHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final ThemeData _epicDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  primaryColor: const Color(0xFF00FFE0),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00FFE0),
    secondary: Color(0xFFFF2E63),
    surface: Color(0xFF1C1C1E),
    background: Color(0xFF0D0D0D),
    error: Color(0xFFFF3B30),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white70, fontFamily: 'Roboto'),
    bodyMedium: TextStyle(color: Colors.white60, fontFamily: 'Roboto'),
    titleLarge: TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
    titleMedium: TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
  ),
  cardTheme: const CardTheme(
    color: Color(0xFF1F1F1F),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    elevation: 6,
    shadowColor: Colors.tealAccent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00FFE0),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 10,
      shadowColor: Colors.tealAccent,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF333333)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00FFE0), width: 2),
    ),
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    labelStyle: const TextStyle(color: Colors.white70),
  ),
);
