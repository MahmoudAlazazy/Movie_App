import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movies/cubit/states.dart';
import 'package:movies/models/movie.dart';

class MovieCubit extends Cubit<MovieState> {
  MovieCubit() : super(MovieInitial());

  Future<void> fetchMovieDetails(int movieId) async {
    try {
      emit(MovieLoading());

      final response = await http
          .get(
            Uri.parse(
              'https://yts.lt/api/v2/movie_details.json?movie_id=$movieId&with_images=true&with_cast=true',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieData = data['data']?['movie'];

        if (movieData == null) {
          emit(MovieError('Movie data not found'));
          return;
        }

        final movie = Movie.fromJson(movieData);
        await fetchSimilarMovies(movieId, movie);
      } else {
        emit(MovieError('Failed to fetch movie details: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MovieError('Error fetching movie details: $e'));
    }
  }

  Future<void> fetchSimilarMovies(int movieId, Movie currentMovie) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://yts.lt/api/v2/movie_suggestions.json?movie_id=$movieId',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final moviesList = data['data']?['movies'] as List?;
        final movies = moviesList
                ?.map((movie) => Movie.fromJson(movie))
                .where((movie) => movie.id != movieId)
                .toList() ??
            [];

        emit(MovieLoaded(currentMovie, similarMovies: movies));
      } else {
        emit(MovieLoaded(currentMovie));
      }
    } catch (e) {
      // عدم إصدار حالة خطأ إذا فشل تحميل الأفلام المشابهة
      print('Error fetching similar movies: $e');
      emit(MovieLoaded(currentMovie));
    }
  }
}
