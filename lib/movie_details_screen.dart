import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movies/core/app_assets.dart';
import 'package:movies/cubit/movie_cubit.dart';
import 'package:movies/cubit/states.dart';
import 'package:movies/widgets/actor_card.dart';
import 'package:movies/widgets/movie_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit()..fetchMovieDetails(movie.id),
      child: MovieDetailsView(initialMovie: movie),
    );
  }
}

class MovieDetailsView extends StatelessWidget {
  final Movie initialMovie;

  const MovieDetailsView({
    super.key,
    required this.initialMovie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return Scaffold(
            backgroundColor: AppAssets.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final movie = state is MovieLoaded ? state.movie : initialMovie;
        final similarMovies = state is MovieLoaded ? state.similarMovies : [];

        return Scaffold(
          backgroundColor: AppAssets.black,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                SizedBox(
                  height: 645,
                  child: Stack(
                    children: [
                      // Movie Poster
                      Image.network(
                        movie.largeCoverImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(18, 19, 18, 0.2),
                              Color.fromRGBO(18, 19, 18, 1),
                            ],
                            stops: [0, 1.0],
                          ),
                        ),
                      ),

                      // Play Button
                      Center(
                        child: GestureDetector(
                          onTap: _launchTrailer,
                          child: SvgPicture.asset(
                            AppAssets.playButton,
                            width: 92,
                            height: 92,
                          ),
                        ),
                      ),

                      // Movie Title
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 8, // Spacing between children
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppAssets.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${movie.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFADADAD),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Watch Button and Watchlist Toggle
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Add movie to history when watched
                          final prefs = await SharedPreferences.getInstance();
                          List<String> history = prefs.getStringList('history') ?? [];
                          if (!history.contains(movie.id.toString())) {
                            history.add(movie.id.toString());
                            await prefs.setStringList('history', history);
                          }
                          _launchTrailer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppAssets.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(double.infinity, 58),
                        ),
                        child: Text(
                          'Watch',
                          style: TextStyle(
                            color: AppAssets.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          final prefs = snapshot.data!;
                          List<String> watchList = prefs.getStringList('watchlist') ?? [];
                          bool isInWatchList = watchList.contains(movie.id.toString());
                          return ElevatedButton.icon(
                            onPressed: () async {
                              List<String> watchList = prefs.getStringList('watchlist') ?? [];
                              if (isInWatchList) {
                                watchList.remove(movie.id.toString());
                              } else {
                                watchList.add(movie.id.toString());
                              }
                              await prefs.setStringList('watchlist', watchList);
                              // Force rebuild to update button state
                              (context as Element).markNeedsBuild();
                            },
                            icon: Icon(isInWatchList ? Icons.check : Icons.add),
                            label: Text(isInWatchList ? 'Remove from Watchlist' : 'Add to Watchlist'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInWatchList ? Colors.grey : Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(double.infinity, 48),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Basic Info
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MovieInfo(
                          icon: AppAssets.heart, text: "${movie.likeCount}"),
                      MovieInfo(icon: AppAssets.time, text: "${movie.runtime}"),
                      MovieInfo(icon: AppAssets.star, text: "${movie.rating}"),
                    ],
                  ),
                ),

                // Screenshots Section
                SectionHeading(title: 'Screenshots'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          movie.largeScreenshot1 ?? '',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey,
                              child: Icon(Icons.error, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 14), // Added spacing
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          movie.largeScreenshot2 ?? '',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey,
                              child: Icon(Icons.error, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 14), // Added spacing
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          movie.largeScreenshot3 ?? '',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey,
                              child: Icon(Icons.error, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Similar Movies Section
                if (similarMovies.isNotEmpty) ...[
                  SectionHeading(title: 'Similar Movies'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: similarMovies
                          .map((movie) => MovieCard(movie: movie))
                          .toList(),
                    ),
                  ),
                ],

                // Summary Section
                if (movie.descriptionFull.isNotEmpty) ...[
                  SectionHeading(title: 'Summary'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      movie.descriptionFull,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                if (movie.cast.isNotEmpty ?? false) ...[
                  SectionHeading(title: 'Cast'),
                  for (var actor in movie.cast) ...[
                    ActorCard(actor: actor),
                  ],
                ],

                // Genres Section
                SectionHeading(title: 'Genres'),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres
                        .map((genre) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppAssets.gray,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: AppAssets.white,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchTrailer() async {
    final movie = initialMovie;
    if (movie.ytTrailerCode.isNotEmpty) {
      final Uri url =
          Uri.parse('https://www.youtube.com/watch?v=${movie.ytTrailerCode}');
      try {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      } catch (e) {
        print('Could not launch trailer: $e');
      }
    }
  }
}

class MovieInfo extends StatelessWidget {
  const MovieInfo({
    super.key,
    required this.icon,
    required this.text,
  });

  final String icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppAssets.gray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppAssets.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;

  const SectionHeading({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppAssets.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
