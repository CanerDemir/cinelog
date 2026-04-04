import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/watchlist_item.dart';
import '../util/app_log.dart';

/// Realtime Database access scoped to the signed-in user: `users/{uid}/watchlist`.
class FirebaseService {
  FirebaseService._();

  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// User-specific watchlist node. Requires [AuthService] / Firebase Auth sign-in.
  static DatabaseReference? _watchlistRefForCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _database.ref('users').child(uid).child('watchlist');
  }

  static DatabaseReference _requireWatchlistRef() {
    final ref = _watchlistRefForCurrentUser();
    if (ref == null) {
      throw StateError('Not signed in');
    }
    return ref;
  }

  /// Streams all watchlist items for the current user.
  static Stream<List<WatchlistItem>> getWatchlistStream() {
    final ref = _watchlistRefForCurrentUser();
    if (ref == null) {
      return Stream.value(<WatchlistItem>[]);
    }
    return ref.onValue.map((event) {
      final List<WatchlistItem> items = [];
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final map = Map<String, dynamic>.from(value);
              map['id'] ??= key.toString();
              items.add(WatchlistItem.fromJson(map));
            } catch (e, st) {
              appLog('Error parsing Firebase item with key $key', e, st);
            }
          }
        });
      }
      return items;
    });
  }

  /// Fetches all watchlist items once for the current user.
  static Future<List<WatchlistItem>> getAllItems() async {
    final ref = _watchlistRefForCurrentUser();
    if (ref == null) return [];
    final snapshot = await ref.get();
    final List<WatchlistItem> items = [];

    if (snapshot.exists && snapshot.value is Map) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        if (value is Map) {
          try {
            final map = Map<String, dynamic>.from(value);
            map['id'] ??= key.toString();
            items.add(WatchlistItem.fromJson(map));
          } catch (e, st) {
            appLog('Error parsing Firebase item with key $key', e, st);
          }
        }
      });
    }
    return items;
  }

  /// Loads a single item by Firebase push key.
  static Future<WatchlistItem?> getItemById(String id) async {
    final ref = _watchlistRefForCurrentUser();
    if (ref == null) return null;
    final snapshot = await ref.child(id).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    if (snapshot.value is! Map) return null;
    try {
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      map['id'] ??= id;
      return WatchlistItem.fromJson(map);
    } catch (e, st) {
      appLog('Error parsing Firebase item $id', e, st);
      return null;
    }
  }

  /// Adds a new item for the current user.
  static Future<void> addItem(WatchlistItem item) async {
    final ref = _requireWatchlistRef();
    final newEntryRef = ref.push();
    item.id = newEntryRef.key;
    await newEntryRef.set(item.toJson());
  }

  /// Updates an existing item using its Firebase ID.
  static Future<void> updateItem(WatchlistItem item) async {
    if (item.id == null) {
      appLog('Cannot update item without Firebase ID');
      return;
    }
    final ref = _requireWatchlistRef();
    await ref.child(item.id!).update(item.toJson());
  }

  /// Deletes an item for the current user.
  static Future<void> deleteItem(WatchlistItem item) async {
    if (item.id == null) {
      appLog('Cannot delete item without Firebase ID');
      return;
    }
    final ref = _requireWatchlistRef();
    await ref.child(item.id!).remove();
  }

  /// Batch-writes items under one [update] per chunk (RTDB-friendly).
  static Future<void> addItemsBatch(
    List<WatchlistItem> items, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (items.isEmpty) return;
    final ref = _requireWatchlistRef();
    const chunkSize = 24;
    var done = 0;
    final total = items.length;
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = min(i + chunkSize, items.length);
      final slice = items.sublist(i, end);
      final Map<String, Object?> updates = {};
      for (final item in slice) {
        final child = ref.push();
        final key = child.key;
        if (key == null) continue;
        item.id = key;
        updates[key] = item.toJson();
      }
      if (updates.isNotEmpty) {
        await ref.update(updates);
      }
      done = end;
      onProgress?.call(done, total);
    }
  }
}
