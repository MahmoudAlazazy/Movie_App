class Movie {
  final int id;
  final String title;
  final String tags;

  Movie({
    required this.id,
    required this.title,
    required this.tags,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['movie_id'],
      title: json['title'],
      tags: json['tags'],
    );
  }
}
