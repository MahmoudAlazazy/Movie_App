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

      final response = await http.get(
        Uri.parse(
          'https://yts.mx/api/v2/movie_details.json?movie_id=$movieId&with_images=true&with_cast=true',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieData = data['data']['movie'];
        final movie = Movie.fromJson(movieData);
        await fetchSimilarMovies(movieId, movie);
      } else {
        emit(MovieError('Failed to fetch movie details'));
      }
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> fetchSimilarMovies(int movieId, Movie currentMovie) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://yts.mx/api/v2/movie_suggestions.json?movie_id=$movieId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['data']['movies'] as List?)
                ?.map((movie) => Movie.fromJson(movie))
                .where((movie) => movie.id != movieId)
                .toList() ??
            [];

        emit(MovieLoaded(currentMovie, similarMovies: movies));
      }
    } catch (e) {
      // Don't emit error state for similar movies failure
      print('Error fetching similar movies: $e');
      emit(MovieLoaded(currentMovie));
    }
  }
}
