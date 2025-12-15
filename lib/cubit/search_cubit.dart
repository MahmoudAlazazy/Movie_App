import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movies/cubit/states.dart';
import 'package:movies/models/movie.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());

      final response = await http.get(
        Uri.parse(
          'https://yts.lt/api/v2/list_movies.json?query_term=$query&limit=20',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['data']['movies'] as List?)
                ?.map((movie) => Movie.fromJson(movie))
                .toList() ??
            [];
        emit(SearchLoaded(movies));
      } else {
        emit(SearchError('Failed to search movies'));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
