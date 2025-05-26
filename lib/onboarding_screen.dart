import 'package:flutter/material.dart';
import 'package:movies/core/app_assets.dart';
import 'package:movies/screens/login_screen.dart';
import 'package:movies/widgets/onboarding_page.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = "OnBoarding";

  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              OnboardingPage(
                image: AppAssets.onboarding1,
                title: 'Find Your Next Favorite Movie Here',
                description:
                'Get access to a huge library of movies to suit all tastes. You will surely like it.',
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                ),
              ),
              OnboardingPage(
                image: AppAssets.onboarding2,
                title: 'Discover Movies',
                description:
                'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onBack: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
              ),
              OnboardingPage(
                image: AppAssets.onboarding3,
                title: 'Explore All Genres',
                description:
                'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onBack: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
              ),
              OnboardingPage(
                image: AppAssets.onboarding4,
                title: 'Create Watchlists',
                description:
                'Save movies to your watchlist to keep track of what you want to watch next.',
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onBack: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
              ),
              OnboardingPage(
                image: AppAssets.onboarding5,
                title: 'Rate, Review, and Learn',
                description:
                "Share your thoughts on the movies you've watched. Dive deep into film details and help others discover great movies with your reviews.",
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onBack: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
              ),
              OnboardingPage(
                image: 'assets/images/OnBoarding6.png',
                title: '    Rate, Review, and Learn   ',
                description: '',
                onBack: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onNext: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                ),
                onFinish: () {
                  // Navigate to the login screen using pushNamed
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}
