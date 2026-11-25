import 'package:flutter/material.dart';
import 'list_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ECHO',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: Color(0xFFd9d9d8),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '"ECHO" - пространство для написания любительских рецензий, в котором вам не надо переживать о том, что ваше мнение о просмотренном контенте раскритикуют или высмеют. Здесь только вы и ваши мысли. Не бойтесь свободно высказываться.\n\nЭто эхо услышите только вы.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6acfc7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45786b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Начать',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}