import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../services/tmdb_api_service.dart';

class MovieRepository {
  final TmdbApiService api;
  MovieRepository(this.api);

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final json = await api.getJson('/movie/popular', query: {
      'page': page.toString(),
      'language': 'es-ES',
    });
    final results = (json['results'] as List<dynamic>?) ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MovieDetail> getMovieDetail(int id) async {
    final json = await api.getJson('/movie/$id', query: {
      'language': 'es-ES',
      'append_to_response': 'credits',
    });
    return MovieDetail.fromJson(json);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final json = await api.getJson('/search/movie', query: {
      'query': query,
      'page': page.toString(),
      'language': 'es-ES',
      'include_adult': 'false',
    });
    final results = (json['results'] as List<dynamic>?) ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> discoverMoviesByDate(DateTime date, {int page = 1}) async {
    final day = date.toIso8601String().split('T').first; // YYYY-MM-DD
    final json = await api.getJson('/discover/movie', query: {
      'primary_release_date.gte': day,
      'primary_release_date.lte': day,
      'sort_by': 'popularity.desc',
      'page': page.toString(),
      'language': 'es-ES',
      'include_adult': 'false',
    });
    final results = (json['results'] as List<dynamic>?) ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}