import '../models/movie_model.dart';

class RecommendationEngine {
  /// ترشيحات حسب النوع
  static List<Movie> recommendByGenre(List<Movie> movies, String genre) {
    genre = genre.toLowerCase().trim();

    return movies
        .where((m) => m.tags.toLowerCase().contains(genre))
        .take(5)
        .toList();
  }

  /// ترشيحات مشابهة لفيلم معين
  static List<Movie> recommendSimilar(List<Movie> movies, String movieName) {
    movieName = movieName.toLowerCase().trim();

    // ابحث عن الفيلم الأساسي
    final movie = movies.firstWhere(
      (m) => m.title.toLowerCase().contains(movieName),
      orElse: () => movies.first,
    );

    // ابحث عن أفلام مشابهة بناءً على تداخل tags
    final movieTags = movie.tags.toLowerCase().split(','); // تقسيم الtags لو مفصولة بفواصل
    final similarMovies = movies.where((m) {
      if (m.id == movie.id) return false;
      final tags = m.tags.toLowerCase();
      // أي تداخل بين tags
      return movieTags.any((tag) => tags.contains(tag));
    }).take(5).toList();

    return similarMovies;
  }
}
