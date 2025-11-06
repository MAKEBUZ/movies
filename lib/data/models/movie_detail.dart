class MovieDetail {
  final int id;
  final String title;
  final String? overview;
  final String? backdropPath;
  final String? posterPath;
  final String? releaseDate;
  final int? runtime;
  final double? voteAverage;
  final List<String> genres;
  final String? director;
  final List<CastMember> cast;

  MovieDetail({
    required this.id,
    required this.title,
    this.overview,
    this.backdropPath,
    this.posterPath,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
    this.genres = const [],
    this.director,
    this.cast = const [],
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genresJson = (json['genres'] as List<dynamic>?) ?? [];
    return MovieDetail(
      id: json['id'] ?? 0,
      title: (json['title'] ?? json['name'] ?? '').toString(),
      overview: json['overview'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int?,
      voteAverage: (json['vote_average'] is num)
          ? (json['vote_average'] as num).toDouble()
          : null,
      genres: genresJson
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
      director: _extractDirector(json['credits'] as Map<String, dynamic>?),
      cast: _extractCast(json['credits'] as Map<String, dynamic>?),
    );
  }

  static String? _extractDirector(Map<String, dynamic>? credits) {
    if (credits == null) return null;
    final crew = (credits['crew'] as List<dynamic>?) ?? [];
    final dir = crew
        .map((e) => e as Map<String, dynamic>)
        .firstWhere(
          (e) => (e['job'] as String?) == 'Director',
          orElse: () => {},
        );
    final name = dir['name'];
    return name is String ? name : null;
  }

  static List<CastMember> _extractCast(Map<String, dynamic>? credits) {
    if (credits == null) return [];
    final cast = (credits['cast'] as List<dynamic>?) ?? [];
    return cast.take(10).map((e) => CastMember.fromJson(e)).toList();
  }
}

class CastMember {
  final String name;
  final String? profilePath;
  CastMember({required this.name, this.profilePath});
  factory CastMember.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return CastMember(
      name: (map['name'] ?? '').toString(),
      profilePath: map['profile_path'] as String?,
    );
  }
}