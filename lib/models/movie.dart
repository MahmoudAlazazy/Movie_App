class Movie {
  final int id;
  final String url;
  final String imdbCode;
  final String title;
  final String titleEnglish;
  final String titleLong;
  final String slug;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String descriptionFull;
  final String synopsis;
  final String ytTrailerCode;
  final String language;
  final String mpaRating;
  final String backgroundImage;
  final String backgroundImageOriginal;
  final String smallCoverImage;
  final String mediumCoverImage;
  final String largeCoverImage;
  final String state;
  final List<Torrent> torrents;
  final String dateUploaded;
  final int dateUploadedUnix;
  final List<String> screenshots;
  final List<Cast> cast;
  final String? mediumScreenshot1;
  final String? mediumScreenshot2;
  final String? mediumScreenshot3;
  final String? largeScreenshot1;
  final String? largeScreenshot2;
  final String? largeScreenshot3;
  final likeCount;

  Movie({
    required this.id,
    required this.url,
    required this.imdbCode,
    required this.title,
    required this.titleEnglish,
    required this.titleLong,
    required this.slug,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    this.summary = '',
    this.descriptionFull = '',
    this.synopsis = '',
    this.ytTrailerCode = '',
    required this.language,
    this.mpaRating = '',
    required this.backgroundImage,
    required this.backgroundImageOriginal,
    required this.smallCoverImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.state,
    required this.torrents,
    required this.dateUploaded,
    required this.dateUploadedUnix,
    this.screenshots = const [],
    this.cast = const [],
    this.mediumScreenshot1,
    this.mediumScreenshot2,
    this.mediumScreenshot3,
    this.largeScreenshot1,
    this.largeScreenshot2,
    this.largeScreenshot3,
    this.likeCount = 0,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      imdbCode: json['imdb_code'] ?? '',
      title: json['title'] ?? '',
      titleEnglish: json['title_english'] ?? '',
      titleLong: json['title_long'] ?? '',
      slug: json['slug'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      runtime: json['runtime'] ?? 0,
      genres: List<String>.from(json['genres'] ?? []),
      summary: json['summary'] ?? '',
      descriptionFull: json['description_full'] ?? '',
      synopsis: json['synopsis'] ?? '',
      ytTrailerCode: json['yt_trailer_code'] ?? '',
      language: json['language'] ?? '',
      mpaRating: json['mpa_rating'] ?? '',
      likeCount: json['like_count'] ?? '',
      backgroundImage: json['background_image'] ?? '',
      backgroundImageOriginal: json['background_image_original'] ?? '',
      smallCoverImage: json['small_cover_image'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      largeCoverImage: json['large_cover_image'] ?? '',
      state: json['state'] ?? '',
      torrents: (json['torrents'] as List?)
              ?.map((torrent) => Torrent.fromJson(torrent))
              .toList() ??
          [],
      dateUploaded: json['date_uploaded'] ?? '',
      dateUploadedUnix: json['date_uploaded_unix'] ?? 0,
      screenshots: [
        if (json['large_screenshot_image1'] != null)
          json['large_screenshot_image1'],
        if (json['large_screenshot_image2'] != null)
          json['large_screenshot_image2'],
        if (json['large_screenshot_image3'] != null)
          json['large_screenshot_image3'],
      ],
      cast:
          (json['cast'] as List?)?.map((x) => Cast.fromJson(x)).toList() ?? [],
      mediumScreenshot1: json['medium_screenshot_image1'],
      mediumScreenshot2: json['medium_screenshot_image2'],
      mediumScreenshot3: json['medium_screenshot_image3'],
      largeScreenshot1: json['large_screenshot_image1'],
      largeScreenshot2: json['large_screenshot_image2'],
      largeScreenshot3: json['large_screenshot_image3'],
    );
  }
}

class Torrent {
  final String url;
  final String hash;
  final String quality;
  final String type;
  final String isRepack;
  final String videoCodec;
  final String bitDepth;
  final String audioChannels;
  final int seeds;
  final int peers;
  final String size;
  final int sizeBytes;
  final String dateUploaded;
  final int dateUploadedUnix;

  Torrent({
    required this.url,
    required this.hash,
    required this.quality,
    required this.type,
    required this.isRepack,
    required this.videoCodec,
    required this.bitDepth,
    required this.audioChannels,
    required this.seeds,
    required this.peers,
    required this.size,
    required this.sizeBytes,
    required this.dateUploaded,
    required this.dateUploadedUnix,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      url: json['url'] ?? '',
      hash: json['hash'] ?? '',
      quality: json['quality'] ?? '',
      type: json['type'] ?? '',
      isRepack: json['is_repack'] ?? '',
      videoCodec: json['video_codec'] ?? '',
      bitDepth: json['bit_depth'] ?? '',
      audioChannels: json['audio_channels'] ?? '',
      seeds: json['seeds'] ?? 0,
      peers: json['peers'] ?? 0,
      size: json['size'] ?? '',
      sizeBytes: json['size_bytes'] ?? 0,
      dateUploaded: json['date_uploaded'] ?? '',
      dateUploadedUnix: json['date_uploaded_unix'] ?? 0,
    );
  }
}

class Cast {
  final String name;
  final String characterName;
  final String urlSmallImage;
  final String imdbCode;

  Cast({
    required this.name,
    required this.characterName,
    required this.urlSmallImage,
    required this.imdbCode,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json['name'] ?? '',
      characterName: json['character_name'] ?? '',
      urlSmallImage: json['url_small_image'] ?? '',
      imdbCode: json['imdb_code'] ?? '',
    );
  }
}
