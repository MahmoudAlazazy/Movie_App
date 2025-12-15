import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "routeName";

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash screen display
    await Future.delayed(Duration(seconds: 3));

    try {
      // Check if user is already logged in
      final User? user = FirebaseAuth.instance.currentUser;
      
      // Check if onboarding was completed
      final prefs = await SharedPreferences.getInstance();
      final showHome = prefs.getBool('showHome') ?? false;

      if (user != null) {
        // User is logged in, go directly to main screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        }
      } else {
        // User is not logged in
        if (mounted) {
          if (showHome) {
            // Onboarding completed, go to login
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          } else {
            // First time user, show onboarding
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnboardingScreen()),
            );
          }
        }
      }
    } catch (e) {
      // Error occurred, default to onboarding
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 821.5,
                width: double.infinity,
                child: Image.asset(
                  'assets/Splash Screen.png',
                  fit: BoxFit.cover,
                )),
          ],
        ),
      ),
    );
  }
}
