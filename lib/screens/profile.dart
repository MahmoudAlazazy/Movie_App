import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movies/models/movie.dart';
import 'package:movies/widgets/movie_card.dart';
import 'update_profile.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "prof";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userPhone = 'Loading...';
  String _userAvatar = 'assets/images/avatar.png';

  List<String> _watchListIds = [];
  List<String> _historyIds = [];
  List<Movie> watchListMovies = [];
  List<Movie> historyMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData(); // Reload data when dependencies change (e.g., when navigating back)
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Mahmoud EL3zaZy';
      _userAvatar = prefs.getString('user_avatar') ?? 'assets/images/avatar.png';
      _watchListIds = prefs.getStringList('watchlist') ?? [];
      _historyIds = prefs.getStringList('history') ?? [];
    });

    watchListMovies = await _getMoviesFromIds(_watchListIds);
    historyMovies = await _getMoviesFromIds(_historyIds);
    setState(() {});
  }

  Future<List<Movie>> _getMoviesFromIds(List<String> ids) async {
    List<Movie> movies = [];
    for (String id in ids) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://yts.lt/api/v2/movie_details.json?movie_id=${int.tryParse(id) ?? 0}&with_images=true',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final movieData = data['data']['movie'];
          movies.add(Movie.fromJson(movieData));
        } else {
          print('Failed to fetch movie details for ID $id: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching movie details for ID $id: $e');
      }
    }
    return movies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.asset(
                          _userAvatar,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 60, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('${watchListMovies.length}', 'Wish List'),
                          _buildStatColumn('${historyMovies.length}', 'History'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, 'update').then((_) {
                        _loadUserData();
                      });
                    },
                    icon: const Icon(Icons.edit, color: Colors.black),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDD835),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text(
                      'Exit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFDD835),
            labelColor: const Color(0xFFFDD835),
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: const [
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Watch List',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'History',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                watchListMovies.isEmpty
                    ? Center(
                        child: Image.asset(
                          'assets/images/Empty.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: watchListMovies.length,
                        itemBuilder: (context, index) {
                          final movie = watchListMovies[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/movie_details',
                                arguments: movie,
                              );
                            },
                            child: MovieCard(movie: movie),
                          );
                        },
                      ),

                historyMovies.isEmpty
                    ? Center(
                        child: Image.asset(
                          'assets/images/Empty.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: historyMovies.length,
                        itemBuilder: (context, index) {
                          final movie = historyMovies[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/movie_details',
                                arguments: movie,
                              );
                            },
                            child: MovieCard(movie: movie),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}