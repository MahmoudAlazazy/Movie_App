import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:movies/cubit/browse_cubit.dart';
import 'package:movies/cubit/states.dart';
import 'package:movies/screens/chatbot_view.dart';
import 'package:movies/widgets/movie_card.dart';

import '../core/app_assets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrowseCubit()..fetchMovies('Action'),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildCarousel(context),
              _buildCategorySection(context, 'Action'),
              _buildCategorySection(context, 'Comedy'),
              _buildCategorySection(context, 'Drama'),
              _buildCategorySection(context, 'Horror'),
              _buildCategorySection(context, 'Thriller'),
              _buildCategorySection(context, 'Adventure'),
              _buildCategorySection(context, 'Fantasy'),
            ],
          ),
        ),

        // إضافة Floating Action Button
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // فتح صفحة الشات بوت
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBotView(),
              ),
            );
          },
          backgroundColor: Color.fromARGB(255, 156, 121, 5),
          child: Icon(Icons.smart_toy ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return BlocBuilder<BrowseCubit, BrowseState>(
      builder: (context, state) {
        if (state is BrowseLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BrowseLoaded) {
          final movies = state.movies;
          ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);

          return SizedBox(
            height: 600,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Background Poster
                ValueListenableBuilder<int>(
                  valueListenable: currentIndexNotifier,
                  builder: (context, index, child) {
                    return Image.network(
                      movies.isNotEmpty ? movies[index].largeCoverImage : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 645,
                    );
                  },
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(18, 19, 18, 0.8),
                        Color.fromRGBO(18, 19, 18, 0.6),
                        Color.fromRGBO(18, 19, 18, 1.0),
                      ],
                      stops: [0, 0.47, 1.0],
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(AppAssets.availableNow),
                ),

                Positioned(
                  bottom: -20,
                  left: 0,
                  right: 0,
                  child: Image.asset(AppAssets.watchNow),
                ),

                // Carousel centered vertically
                Center(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 320,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.55,
                      autoPlay: false,
                      onPageChanged: (index, reason) {
                        currentIndexNotifier.value = index;
                      },
                    ),
                    items: movies.map((movie) {
                      return Builder(
                        builder: (BuildContext context) {
                          return MovieCard(
                            movie: movie,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('Failed to load movies'));
        }
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, String category) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category,
                    style: TextStyle(color: AppAssets.white, fontSize: 24)),
                TextButton(
                  onPressed: () {},
                  child: Text('See More',
                      style: TextStyle(color: AppAssets.primary)),
                ),
              ],
            ),
          ),

          // Horizontal Movie List
          Container(
            padding: EdgeInsets.only(left: 16),
            height: 220,
            child: BlocBuilder<BrowseCubit, BrowseState>(
              builder: (context, state) {
                if (state is BrowseLoaded) {
                  final filteredMovies = state.movies
                      .where((movie) => movie.genres.contains(category))
                      .toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredMovies.length,
                    separatorBuilder: (context, index) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return MovieCard(movie: filteredMovies[index]);
                    },
                  );
                } else {
                  return Center(child: Text('No movies available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
