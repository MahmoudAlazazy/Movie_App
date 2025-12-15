class OfflineMovie {
  final int id;
  final String title;
  final String titleEnglish;
  final String filePath;
  final String coverPath;
  final String quality;
  final int fileSize;
  final DateTime downloadDate;
  final bool isDownloaded;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String language;
  final String backgroundImage;

  OfflineMovie({
    required this.id,
    required this.title,
    required this.titleEnglish,
    required this.filePath,
    required this.coverPath,
    required this.quality,
    required this.fileSize,
    required this.downloadDate,
    required this.isDownloaded,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.language,
    required this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleEnglish': titleEnglish,
      'filePath': filePath,
      'coverPath': coverPath,
      'quality': quality,
      'fileSize': fileSize,
      'downloadDate': downloadDate.toIso8601String(),
      'isDownloaded': isDownloaded ? 1 : 0,
      'rating': rating,
      'runtime': runtime,
      'genres': genres.join(','),
      'summary': summary,
      'language': language,
      'backgroundImage': backgroundImage,
    };
  }

  factory OfflineMovie.fromMap(Map<String, dynamic> map) {
    return OfflineMovie(
      id: map['id'],
      title: map['title'],
      titleEnglish: map['titleEnglish'],
      filePath: map['filePath'],
      coverPath: map['coverPath'],
      quality: map['quality'],
      fileSize: map['fileSize'],
      downloadDate: DateTime.parse(map['downloadDate']),
      isDownloaded: map['isDownloaded'] == 1,
      rating: map['rating'],
      runtime: map['runtime'],
      genres: (map['genres'] as String).split(','),
      summary: map['summary'],
      language: map['language'],
      backgroundImage: map['backgroundImage'],
    );
  }
}
