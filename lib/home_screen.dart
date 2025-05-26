import 'package:flutter/material.dart';
import 'package:movies/screens/browse_tab.dart';
import 'package:movies/screens/home_tab.dart';
import 'package:movies/screens/profile.dart';
import 'package:movies/screens/search_tab.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = "Home";

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeTab(),
    SearchTab(),
    BrowseTab(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,

      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(top: 10, right: 10, left: 10),
        color: Color(0xFF282828),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF282828),
          items: [
            _buildNavItem(Icons.home, 'Home'),
            _buildNavItem(Icons.search, 'Search'),
            _buildNavItem(Icons.explore, 'Browse'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}
