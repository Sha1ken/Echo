import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF212121),
        primaryColor: const Color(0xFF45786b),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF45786b),
          secondary: Color(0xFF6acfc7),
          surface: Color(0xFF2C2C2C),
        ),
        fontFamily: 'Open Sans',
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF212121),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6acfc7)),
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}