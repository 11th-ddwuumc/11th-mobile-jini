class TmdbMovieDetailDto {
  const TmdbMovieDetailDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    required this.genres,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final int? runtime;
  final List<String> genres;

  factory TmdbMovieDetailDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDetailDto(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map(
            (genre) => (genre as Map<String, dynamic>)['name'] as String? ?? '',
          )
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}
