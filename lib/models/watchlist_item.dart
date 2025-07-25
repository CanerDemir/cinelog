import 'package:hive/hive.dart';

part 'watchlist_item.g.dart';

@HiveType(typeId: 0)
class WatchlistItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String type; // 'movie' or 'tv'

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? genre;

  @HiveField(4)
  int? year;

  @HiveField(5)
  bool isWatched;

  @HiveField(6)
  DateTime dateAdded;

  @HiveField(7)
  int? rating; // 1-5 stars

  @HiveField(8)
  String? posterUrl; // URL for movie poster
  
  @HiveField(9)
  bool isFavorite; // Whether the item is favorited
  
  @HiveField(10)
  double? imdbRating; // IMDb rating (0-10)
  
  @HiveField(11)
  int? imdbVotes; // Number of IMDb votes
  
  @HiveField(12)
  String? imdbId; // IMDb ID

  WatchlistItem({
    required this.title,
    required this.type,
    this.description,
    this.genre,
    this.year,
    this.isWatched = false,
    required this.dateAdded,
    this.rating,
    this.posterUrl,
    this.isFavorite = false,
    this.imdbRating,
    this.imdbVotes,
    this.imdbId,
  });
}