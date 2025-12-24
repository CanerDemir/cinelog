import 'package:firebase_database/firebase_database.dart';
import '../models/watchlist_item.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _watchlistNode = 'watchlist';

  static DatabaseReference get _watchlistRef => _database.ref(_watchlistNode);

  /// Streams all watchlist items from Firebase Realtime Database
  static Stream<List<WatchlistItem>> getWatchlistStream() {
    return _watchlistRef.onValue.map((event) {
      final List<WatchlistItem> items = [];
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            try {
              // Ensure we convert dynamic map to Map<String, dynamic>
              final map = Map<String, dynamic>.from(value);
              items.add(WatchlistItem.fromJson(map));
            } catch (e) {
              print('Error parsing Firebase item with key $key: $e');
            }
          }
        });
      }
      return items;
    });
  }

  /// Fetches all watchlist items once
  static Future<List<WatchlistItem>> getAllItems() async {
    final snapshot = await _watchlistRef.get();
    final List<WatchlistItem> items = [];

    if (snapshot.exists && snapshot.value is Map) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        if (value is Map) {
          try {
            final map = Map<String, dynamic>.from(value);
            items.add(WatchlistItem.fromJson(map));
          } catch (e) {
            print('Error parsing Firebase item with key $key: $e');
          }
        }
      });
    }
    return items;
  }

  /// Adds a new item to Firebase
  static Future<void> addItem(WatchlistItem item) async {
    final newEntryRef = _watchlistRef.push();
    item.id = newEntryRef.key;
    await newEntryRef.set(item.toJson());
  }

  /// Updates an existing item using its Firebase ID
  static Future<void> updateItem(WatchlistItem item) async {
    if (item.id == null) {
      print('Cannot update item without Firebase ID');
      return;
    }
    await _watchlistRef.child(item.id!).update(item.toJson());
  }

  /// Deletes an item from Firebase using its ID
  static Future<void> deleteItem(WatchlistItem item) async {
    if (item.id == null) {
      print('Cannot delete item without Firebase ID');
      return;
    }
    await _watchlistRef.child(item.id!).remove();
  }
}
