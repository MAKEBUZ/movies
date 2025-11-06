import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/constants/tmdb_config.dart';

class TmdbApiService {
  final http.Client _client;
  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers() => {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${TmdbConfig.readAccessToken}', // v4 token
      };

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'api_key': TmdbConfig.apiKey, // v3 api key
      ...?query,
    };

    final uri = Uri.https('api.themoviedb.org', '/3$path', mergedQuery);
    final response = await _client.get(uri, headers: _headers());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
        'TMDB error: ${response.statusCode} ${response.reasonPhrase}');
  }
}