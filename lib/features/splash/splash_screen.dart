import 'package:flutter/material.dart';
import 'package:whats_app/colors.dart';
import 'package:whats_app/core/services/preference_manager.dart';
import 'package:whats_app/features/chat/screens/chat_home_screen.dart';
import '../landing/screens/landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigation();
  }

  Future<void> navigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool? login = PreferencesManager().getBool('is_login');

    if (login == null || login == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Builder(
            builder: (context) {
              return const ChatHomeScreen();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(child: Icon(Icons.phone, color: Colors.green, size: 100)),
    );
  }
}
