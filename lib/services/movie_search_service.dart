import 'dart:convert';
import 'package:http/http.dart' as http;
import 'imdb_service.dart';

class MovieSearchResult {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? releaseDate;
  final List<String> genres;
  final double? voteAverage;
  final String mediaType; // 'movie' or 'tv'
  IMDbData? imdbData;

  MovieSearchResult({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.genres = const [],
    this.voteAverage,
    required this.mediaType,
    this.imdbData,
  });

  String get fullPosterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }
    
    // Handle TMDB-style paths
    if (posterPath!.startsWith('/')) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    
    return posterPath!;
  }

  int? get year => releaseDate != null 
      ? DateTime.tryParse(releaseDate!)?.year
      : null;

  factory MovieSearchResult.fromJson(Map<String, dynamic> json, String mediaType) {
    return MovieSearchResult(
      id: json['id'],
      title: mediaType == 'movie' ? json['title'] ?? 'Unknown Title' : json['name'] ?? 'Unknown Title',
      overview: json['overview'],
      posterPath: json['poster_path'],
      releaseDate: mediaType == 'movie' ? json['release_date'] : json['first_air_date'],
      voteAverage: json['vote_average'] != null ? (json['vote_average'] is int ? (json['vote_average'] as int).toDouble() : json['vote_average']?.toDouble()) : null,
      mediaType: mediaType,
      genres: [],  // Genres are fetched separately in the details call
    );
  }
}

class MovieSearchService {
  static const String _apiKey = '3a224d1de2202bd05b0e744f2b2ce66d'; // TMDB API key
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // Use real data from TMDB API
  static const bool _useMockData = false;

  static Future<List<MovieSearchResult>> searchMulti(String query) async {
    if (query.isEmpty) return [];
    
    if (_useMockData) {
      return _getMockResults(query);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <MovieSearchResult>[];
        
        for (final item in data['results']) {
          if (item['media_type'] == 'movie' || item['media_type'] == 'tv') {
            results.add(MovieSearchResult.fromJson(item, item['media_type']));
          }
        }
        
        return results.take(10).toList();
      }
    } catch (e) {
      print('Error searching movies: $e');
    }
    
    return [];
  }

  static Future<MovieSearchResult?> getDetails(int id, String mediaType) async {
    if (_useMockData) {
      return _getMockDetails(id, mediaType);
    }

    try {
      final endpoint = mediaType == 'movie' ? 'movie' : 'tv';
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint/$id?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = (data['genres'] as List?)
            ?.map((g) => g['name'] as String)
            .toList() ?? [];
        
        final title = mediaType == 'movie' ? data['title'] : data['name'];
        final releaseDate = mediaType == 'movie' ? data['release_date'] : data['first_air_date'];
        final year = releaseDate != null ? DateTime.tryParse(releaseDate)?.year.toString() : null;
        
        final result = MovieSearchResult(
          id: data['id'],
          title: title,
          overview: data['overview'],
          posterPath: data['poster_path'],
          releaseDate: releaseDate,
          genres: genres,
          voteAverage: data['vote_average']?.toDouble(),
          mediaType: mediaType,
        );
        
        // Fetch IMDb data
        try {
          result.imdbData = await IMDbService.getIMDbDataByTitle(title, year: year);
        } catch (e) {
          print('Error fetching IMDb data: $e');
        }
        
        return result;
      }
    } catch (e) {
      print('Error getting movie details: $e');
    }
    
    return null;
  }

  // Mock data for demo purposes
  static Future<List<MovieSearchResult>> _getMockResults(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final mockResults = <MovieSearchResult>[];
    
    if (query.toLowerCase().contains('avatar')) {
      mockResults.addAll([
        MovieSearchResult(
          id: 19995,
          title: 'Avatar',
          overview: 'In the 22nd century, a paraplegic Marine is dispatched to the moon Pandora on a unique mission.',
          posterPath: 'https://picsum.photos/id/237/500/750',
          releaseDate: '2009-12-18',
          genres: ['Action', 'Adventure', 'Fantasy', 'Science Fiction'],
          voteAverage: 7.6,
          mediaType: 'movie',
        ),
        MovieSearchResult(
          id: 76600,
          title: 'Avatar: The Way of Water',
          overview: 'Set more than a decade after the events of the first film, learn the story of the Sully family.',
          posterPath: 'https://picsum.photos/id/238/500/750',
          releaseDate: '2022-12-16',
          genres: ['Science Fiction', 'Adventure', 'Action'],
          voteAverage: 7.7,
          mediaType: 'movie',
        ),
      ]);
    }
    
    if (query.toLowerCase().contains('breaking')) {
      mockResults.add(
        MovieSearchResult(
          id: 1396,
          title: 'Breaking Bad',
          overview: 'A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine.',
          posterPath: 'https://picsum.photos/id/239/500/750',
          releaseDate: '2008-01-20',
          genres: ['Drama', 'Crime'],
          voteAverage: 9.5,
          mediaType: 'tv',
        ),
      );
    }
    
    if (query.toLowerCase().contains('inception')) {
      mockResults.add(
        MovieSearchResult(
          id: 27205,
          title: 'Inception',
          overview: 'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets.',
          posterPath: 'https://picsum.photos/id/240/500/750',
          releaseDate: '2010-07-16',
          genres: ['Action', 'Science Fiction', 'Adventure'],
          voteAverage: 8.4,
          mediaType: 'movie',
        ),
      );
    }
    
    if (query.toLowerCase().contains('stranger')) {
      mockResults.add(
        MovieSearchResult(
          id: 66732,
          title: 'Stranger Things',
          overview: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments.',
          posterPath: 'https://picsum.photos/id/241/500/750',
          releaseDate: '2016-07-15',
          genres: ['Drama', 'Fantasy', 'Horror'],
          voteAverage: 8.6,
          mediaType: 'tv',
        ),
      );
    }
    
    // Generic results for any other query
    if (mockResults.isEmpty) {
      mockResults.addAll([
        MovieSearchResult(
          id: 550,
          title: 'Fight Club',
          overview: 'An insomniac office worker and a devil-may-care soapmaker form an underground fight club.',
          posterPath: 'https://picsum.photos/id/242/500/750',
          releaseDate: '1999-10-15',
          genres: ['Drama'],
          voteAverage: 8.4,
          mediaType: 'movie',
        ),
        MovieSearchResult(
          id: 238,
          title: 'The Godfather',
          overview: 'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.',
          posterPath: 'https://picsum.photos/id/243/500/750',
          releaseDate: '1972-03-24',
          genres: ['Drama', 'Crime'],
          voteAverage: 9.2,
          mediaType: 'movie',
        ),
      ]);
    }
    
    return mockResults;
  }

  static Future<MovieSearchResult?> _getMockDetails(int id, String mediaType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return the same mock data with more details
    final mockResults = await _getMockResults('');
    return mockResults.firstWhere(
      (result) => result.id == id && result.mediaType == mediaType,
      orElse: () => MovieSearchResult(
        id: id,
        title: 'Sample Title',
        overview: 'Sample overview for this item.',
        posterPath: 'https://picsum.photos/id/244/500/750',
        releaseDate: '2023-01-01',
        genres: ['Drama'],
        voteAverage: 7.0,
        mediaType: mediaType,
      ),
    );
  }
}