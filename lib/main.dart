import 'package:flutter/material.dart';
import 'package:movies/home_screen.dart';
import 'package:movies/screens/forget_password.dart';
import 'package:movies/screens/login_screen.dart';
import 'package:movies/screens/profile.dart';
import 'package:movies/screens/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movies/onboarding_screen.dart';
import 'package:movies/splash_screen.dart';
import 'package:movies/screens/register.dart';
import 'package:movies/auth_wrapper.dart';
import 'package:movies/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();

  // Shared Preferences لتحديد ما إذا كان Onboarding تم عرضه أم لا
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  // Load theme preference
  await ThemeService().loadTheme();

  runApp(MyApp(showHome: showHome));
}

// دالة اختبار للاتصال بـ Firebase
Future<void> testFirebaseConnection() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    print('✅ Firebase connection successful');
    if (user != null) {
      print('👤 User is signed in: ${user.email}');
    } else {
      print('👤 No user signed in.');
    }
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool showHome;

  const MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Movie App',
          theme: ThemeService().currentTheme,
          initialRoute: SplashScreen.routeName,
          routes: {
            AuthWrapper.routeName: (context) => AuthWrapper(),
            MainScreen.routeName: (context) => MainScreen(),
            OnboardingScreen.routeName: (context) => OnboardingScreen(),
            SplashScreen.routeName: (context) => SplashScreen(),
            LoginScreen.routeName: (context) => LoginScreen(),
            RegisterScreen.routeName: (context) => RegisterScreen(),
            ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
            ProfileScreen.routeName: (context) => ProfileScreen(),
            UpdateProfileScreen.routeName: (context) => UpdateProfileScreen(),
          },
        );
      },
    );
  }
}
