import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../util/app_log.dart';

class IMDbData {
  final String imdbId;
  final double rating;
  final int voteCount;
  final String? actors;
  final String? year;

  IMDbData({
    required this.imdbId,
    required this.rating,
    required this.voteCount,
    this.actors,
    this.year,
  });

  factory IMDbData.fromJson(Map<String, dynamic> json) {
    return IMDbData(
      imdbId: json['imdbID'] ?? '',
      rating: double.tryParse(json['imdbRating'] ?? '0') ?? 0.0,
      voteCount: int.tryParse((json['imdbVotes'] ?? '0').replaceAll(',', '')) ??
          0,
      actors: json['Actors'],
      year: json['Year'],
    );
  }
}

/// Loads ratings and cast from [OMDb](https://www.omdbapi.com/) (by IMDb ID search).
class IMDbService {
  static String get _apiKey => ApiKeys.omdb;
  static const String _host = 'www.omdbapi.com';

  /// [mediaType] is `movie` or `tv` (maps to OMDb `series`).
  static Future<IMDbData?> getIMDbDataByTitle(
    String title, {
    String? year,
    String mediaType = 'movie',
  }) async {
    final isTv = mediaType == 'tv';
    IMDbData? r =
        await _requestOmdb(title, year: year, type: isTv ? 'series' : 'movie');
    if (r != null) return r;
    r = await _requestOmdb(title, year: year, type: isTv ? 'movie' : 'series');
    if (r != null) return r;
    return _requestOmdb(title, year: year, type: null);
  }

  static Future<IMDbData?> _requestOmdb(
    String title, {
    String? year,
    String? type,
  }) async {
    try {
      final params = <String, String>{'apikey': _apiKey, 't': title};
      if (year != null && year.isNotEmpty) {
        params['y'] = year;
      }
      if (type != null) {
        params['type'] = type;
      }
      final uri = Uri.https(_host, '/', params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['Response'] == 'True') {
          return IMDbData.fromJson(data);
        }
      }
    } catch (e, st) {
      appLog('Error fetching OMDb data', e, st);
    }
    return null;
  }
}
