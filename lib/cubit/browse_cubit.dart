import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movies/cubit/states.dart';

import '../models/movie.dart';

class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit() : super(BrowseInitial());

  Future<void> fetchMovies(String category) async {
    try {
      emit(BrowseLoading());

      final response = await http.get(
        Uri.parse(
          'https://yts.mx/api/v2/list_movies.json?limit=20&genre=$category',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['data']['movies'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        emit(BrowseLoaded(movies, category));
      } else {
        emit(BrowseError('Failed to fetch movies'));
      }
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }

  void changeCategory(String category) {
    fetchMovies(category);
  }
}
