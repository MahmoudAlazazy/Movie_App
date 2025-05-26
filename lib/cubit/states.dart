
import '../models/movie.dart';

// Movie States
abstract class MovieState {
  const MovieState();
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final Movie movie;
  final List<Movie> similarMovies;

  const MovieLoaded(this.movie, {this.similarMovies = const []});
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);
}

// Browse States
abstract class BrowseState {
  const BrowseState();
}

class BrowseInitial extends BrowseState {}

class BrowseLoading extends BrowseState {}

class BrowseLoaded extends BrowseState {
  final List<Movie> movies;
  final String currentCategory;

  const BrowseLoaded(this.movies, this.currentCategory);
}

class BrowseError extends BrowseState {
  final String message;

  const BrowseError(this.message);
}

// Search States
abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Movie> movies;

  const SearchLoaded(this.movies);
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);
}
