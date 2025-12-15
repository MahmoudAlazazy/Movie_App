import 'package:flutter/material.dart';
import 'package:movies/movie_details_screen.dart';

import '../core/app_assets.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              movie.mediumCoverImage,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/Empty.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(100, 0, 0, 0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.rating.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.star_rounded,
                  color: AppAssets.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
