import 'dart:convert';
import 'package:http/http.dart' as http;

class IMDbData {
  final String imdbId;
  final double rating;
  final int voteCount;
  
  IMDbData({
    required this.imdbId,
    required this.rating,
    required this.voteCount,
  });
  
  factory IMDbData.fromJson(Map<String, dynamic> json) {
    return IMDbData(
      imdbId: json['id'] ?? '',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
      voteCount: json['voteCount'] != null ? int.tryParse(json['voteCount'].toString()) ?? 0 : 0,
    );
  }
}

class IMDbService {
  // Using OMDb API as a proxy to get IMDb data
  static const String _apiKey = 'YOUR_OMDB_API_KEY'; // Replace with your OMDb API key
  static const String _baseUrl = 'https://www.omdbapi.com/';
  
  // For demo purposes, we'll simulate responses
  static const bool _useMockData = true;
  
  // Get IMDb data by title and year
  static Future<IMDbData?> getIMDbDataByTitle(String title, {String? year}) async {
    if (_useMockData) {
      return _getMockIMDbData(title, year);
    }
    
    try {
      final queryParams = {
        'apikey': _apiKey,
        't': title,
        'type': 'movie',
      };
      
      if (year != null) {
        queryParams['y'] = year;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl').replace(queryParameters: queryParams),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return IMDbData(
            imdbId: data['imdbID'] ?? '',
            rating: double.tryParse(data['imdbRating'] ?? '0') ?? 0.0,
            voteCount: _parseVoteCount(data['imdbVotes'] ?? '0'),
          );
        }
      }
    } catch (e) {
      print('Error fetching IMDb data: $e');
    }
    
    return null;
  }
  
  // Parse vote count from IMDb format (e.g., "1,234,567")
  static int _parseVoteCount(String votes) {
    try {
      return int.parse(votes.replaceAll(',', ''));
    } catch (e) {
      return 0;
    }
  }
  
  // Mock IMDb data for demo purposes
  static Future<IMDbData?> _getMockIMDbData(String title, String? year) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // Normalize title for comparison
    final normalizedTitle = title.toLowerCase().trim();
    
    // Popular movies with mock IMDb data
    if (normalizedTitle.contains('avatar')) {
      return IMDbData(
        imdbId: 'tt0499549',
        rating: 7.9,
        voteCount: 1234567,
      );
    }
    
    if (normalizedTitle.contains('inception')) {
      return IMDbData(
        imdbId: 'tt1375666',
        rating: 8.8,
        voteCount: 2345678,
      );
    }
    
    if (normalizedTitle.contains('godfather')) {
      return IMDbData(
        imdbId: 'tt0068646',
        rating: 9.2,
        voteCount: 1789456,
      );
    }
    
    if (normalizedTitle.contains('dark knight')) {
      return IMDbData(
        imdbId: 'tt0468569',
        rating: 9.0,
        voteCount: 2456789,
      );
    }
    
    if (normalizedTitle.contains('pulp fiction')) {
      return IMDbData(
        imdbId: 'tt0110912',
        rating: 8.9,
        voteCount: 1987654,
      );
    }
    
    if (normalizedTitle.contains('fight club')) {
      return IMDbData(
        imdbId: 'tt0137523',
        rating: 8.8,
        voteCount: 1876543,
      );
    }
    
    // For TV shows
    if (normalizedTitle.contains('breaking bad')) {
      return IMDbData(
        imdbId: 'tt0903747',
        rating: 9.5,
        voteCount: 1654321,
      );
    }
    
    if (normalizedTitle.contains('game of thrones')) {
      return IMDbData(
        imdbId: 'tt0944947',
        rating: 9.2,
        voteCount: 1876543,
      );
    }
    
    if (normalizedTitle.contains('stranger things')) {
      return IMDbData(
        imdbId: 'tt4574334',
        rating: 8.7,
        voteCount: 1234567,
      );
    }
    
    // Default mock data for any other title
    return IMDbData(
      imdbId: 'tt0000000',
      rating: 7.5 + (normalizedTitle.length % 25) / 10, // Generate a random-ish rating between 7.5 and 10.0
      voteCount: 100000 + (normalizedTitle.length * 10000), // Generate a random-ish vote count
    );
  }
}