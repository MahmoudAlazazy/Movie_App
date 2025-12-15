import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';
import 'intent_detector.dart';
import 'recommendation_engine.dart';

class ChatBotService {
  List<Movie> _movies = [];

  /// خريطة لتحويل الأنواع العربية للإنجليزية
  final Map<String, String> _genreMap = {
    'اكشن': 'action',
    'رعب': 'horror',
    'خيال علمي': 'sci-fi',
    'رومانسي': 'romance',
    'كوميدي': 'comedy',
    'دراما': 'drama',
    'مغامرة': 'adventure',
    'تشويق': 'thriller',
    'جريمة': 'crime',
    'فانتازيا': 'fantasy',
  };

  Future<void> loadData() async {
    try {
      final data = await rootBundle.loadString('assets/model_ai/movie_data.json');
      final List decoded = json.decode(data);
      _movies = decoded.map((e) => Movie.fromJson(e)).toList();

      if (kDebugMode) {
        print('Loaded ${_movies.length} movies');
        if (_movies.isNotEmpty) {
          print('First movie: ${_movies.first.title}');
          print('First movie tags: ${_movies.first.tags}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading movie data: $e');
      }
    }
  }

  String reply(String message) {
    final intent = IntentDetector.detectIntent(message);

    if (intent == 'genre_recommend') {
      final genre = IntentDetector.extractGenre(message, _genreMap);

      if (genre == null) {
        return 'تحب نوع ايه؟ اكشن، رعب، خيال علمي...';
      }

      final recs = RecommendationEngine.recommendByGenre(_movies, genre);
      return _formatMovies(recs);
    }

    if (intent == 'similar_movie') {
      // إزالة الكلمات الزائدة قبل البحث
      final name = message
          .replaceAll('زي', '')
          .replaceAll('مشابه', '')
          .replaceAll('شبيه', '')
          .replaceAll('مثل', '')
          .trim();

      final recs = RecommendationEngine.recommendSimilar(_movies, name);
      return _formatMovies(recs);
    }

    return 'مش فاهمك 🤔 جرب تقول: عاوز فيلم اكشن';
  }

  String _formatMovies(List<Movie> movies) {
    if (movies.isEmpty) return 'مفيش ترشيحات حالياً';

    return movies.map((m) => '🎬 ${m.title}').join('\n');
  }
}
