import 'package:hive_flutter/hive_flutter.dart';
import '../models/watchlist_item.dart';

class StorageService {
  static const String _boxName = 'watchlist';
  static Box<WatchlistItem>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WatchlistItemAdapter());
    _box = await Hive.openBox<WatchlistItem>(_boxName);
  }

  static Box<WatchlistItem> get box {
    if (_box == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    return _box!;
  }

  static List<WatchlistItem> getAllItems() {
    return box.values.toList();
  }

  static List<WatchlistItem> getMovies() {
    return box.values.where((item) => item.type == 'movie').toList();
  }

  static List<WatchlistItem> getTVSeries() {
    return box.values.where((item) => item.type == 'tv').toList();
  }

  static List<WatchlistItem> getWatchedItems() {
    return box.values.where((item) => item.isWatched).toList();
  }

  static List<WatchlistItem> getUnwatchedItems() {
    return box.values.where((item) => !item.isWatched).toList();
  }

  static Future<void> addItem(WatchlistItem item) async {
    await box.add(item);
  }

  static Future<void> updateItem(WatchlistItem item) async {
    await item.save();
  }

  static Future<void> deleteItem(WatchlistItem item) async {
    await item.delete();
  }

  static Future<void> clearAll() async {
    await box.clear();
  }
}