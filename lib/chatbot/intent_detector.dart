class IntentDetector {
  static String detectIntent(String message) {
    message = message.toLowerCase();

    // Similar movie patterns
    if (message.contains('زي') || message.contains('مشابه') || 
        message.contains('شبيه') || message.contains('مثل')) {
      return 'similar_movie';
    }

    // Genre recommendation patterns - more comprehensive
    if (message.contains('فيلم') || message.contains('افلام') ||
        message.contains('حاجة') || message.contains('عن') ||
        message.contains('بحث') || message.contains('اقترح') ||
        message.contains('جيب') || message.contains('هات') ||
        message.contains('ارشحني') || message.contains('دلني') ||
        message.contains('عاوز') || message.contains('ابغى') ||
        message.contains('احب') || message.contains('مفضل')) {
      return 'genre_recommend';
    }

    return 'unknown';
  }

  static String? extractGenre(String message, Map<String, String> genreMap) {
    // خريطة الأنواع العربية → الإنجليزية (مطابقة مع JSON)
    const genreMap = {
      'اكشن': 'action',
      'رعب': 'horror',
      'خيال علمي': 'sci-fi',
      'رومانسي': 'romance',
      'كوميدي': 'comedy',
      'دراما': 'drama',
      'مغامرة': 'adventure',
      'تشويق': 'thriller',
      'جريمة': 'crime',
      'فانتازيا': 'fantasy'
    };

    message = message.toLowerCase().trim();
    
    // البحث بالعربي
    for (var arabicGenre in genreMap.keys) {
      if (message.contains(arabicGenre.toLowerCase())) {
        return genreMap[arabicGenre];
      }
    }
    
    // البحث بالإنجليزي
    for (var genre in genreMap.values) {
      if (message.contains(genre.toLowerCase())) {
        return genre;
      }
    }
    
    return null;
  }
}
