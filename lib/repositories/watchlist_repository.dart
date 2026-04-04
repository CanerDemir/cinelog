import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/watchlist_item.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

/// Watchlist persistence — Firebase for registered users, Hive for guest mode.
abstract class WatchlistRepository {
  Stream<List<WatchlistItem>> watchItems();

  Future<List<WatchlistItem>> loadSnapshot();

  Future<WatchlistItem?> getItemById(String id);

  Future<void> addItem(WatchlistItem item);

  Future<void> updateItem(WatchlistItem item);

  Future<void> deleteItem(WatchlistItem item);

  /// Imports items; skips duplicates (title + year + type). [onProgress] reports processed count.
  Future<({int added, int skipped, String message})> importItems(
    List<WatchlistItem> parsed, {
    void Function(int done, int total)? onProgress,
  });
}

class FirebaseWatchlistRepository implements WatchlistRepository {
  @override
  Stream<List<WatchlistItem>> watchItems() => FirebaseService.getWatchlistStream();

  @override
  Future<List<WatchlistItem>> loadSnapshot() => FirebaseService.getAllItems();

  @override
  Future<WatchlistItem?> getItemById(String id) => FirebaseService.getItemById(id);

  @override
  Future<void> addItem(WatchlistItem item) => FirebaseService.addItem(item);

  @override
  Future<void> updateItem(WatchlistItem item) => FirebaseService.updateItem(item);

  @override
  Future<void> deleteItem(WatchlistItem item) => FirebaseService.deleteItem(item);

  @override
  Future<({int added, int skipped, String message})> importItems(
    List<WatchlistItem> parsed, {
    void Function(int done, int total)? onProgress,
  }) async {
    final existing = await FirebaseService.getAllItems();
    final toAdd = <WatchlistItem>[];
    var skipped = 0;
    for (final n in parsed) {
      n.id = null;
      final exists = existing.any((e) =>
          e.title == n.title && e.year == n.year && e.type == n.type);
      if (exists) {
        skipped++;
      } else {
        toAdd.add(n);
        existing.add(n);
      }
    }
    final total = toAdd.length;
    if (total == 0) {
      onProgress?.call(0, 0);
      return (
        added: 0,
        skipped: skipped,
        message:
            'Import successful: 0 items added, $skipped skipped (synced to cloud)',
      );
    }
    await FirebaseService.addItemsBatch(toAdd, onProgress: (done, _) {
      onProgress?.call(done, total);
    });
    return (
      added: total,
      skipped: skipped,
      message:
          'Import successful: $total items added, $skipped skipped (synced to cloud)',
    );
  }
}

class HiveWatchlistRepository implements WatchlistRepository {
  Box<WatchlistItem> get _box => StorageService.box;

  @override
  Future<List<WatchlistItem>> loadSnapshot() async => StorageService.getAllItems();

  @override
  Stream<List<WatchlistItem>> watchItems() {
    late StreamController<List<WatchlistItem>> c;
    c = StreamController<List<WatchlistItem>>(
      onListen: () {
        void emit() {
          if (!c.isClosed) {
            c.add(StorageService.getAllItems());
          }
        }

        emit();
        final listenable = _box.listenable();
        listenable.addListener(emit);
        c.onCancel = () => listenable.removeListener(emit);
      },
    );
    return c.stream;
  }

  @override
  Future<WatchlistItem?> getItemById(String id) async {
    final asInt = int.tryParse(id);
    if (asInt != null) {
      final v = _box.get(asInt);
      if (v != null) return v;
    }
    for (final item in _box.values) {
      if (item.id == id || item.key?.toString() == id) return item;
    }
    return null;
  }

  @override
  Future<void> addItem(WatchlistItem item) async {
    await StorageService.addItem(item);
    if (item.key != null) {
      item.id = item.key.toString();
      await item.save();
    }
  }

  @override
  Future<void> updateItem(WatchlistItem item) => StorageService.updateItem(item);

  @override
  Future<void> deleteItem(WatchlistItem item) => StorageService.deleteItem(item);

  @override
  Future<({int added, int skipped, String message})> importItems(
    List<WatchlistItem> parsed, {
    void Function(int done, int total)? onProgress,
  }) async {
    final existing = StorageService.getAllItems();
    final toAdd = <WatchlistItem>[];
    var skipped = 0;
    for (final n in parsed) {
      n.id = null;
      final exists = existing.any((e) =>
          e.title == n.title && e.year == n.year && e.type == n.type);
      if (exists) {
        skipped++;
      } else {
        toAdd.add(n);
        existing.add(n);
      }
    }
    final total = toAdd.length;
    for (var i = 0; i < toAdd.length; i++) {
      await StorageService.addItem(toAdd[i]);
      onProgress?.call(i + 1, total);
    }
    if (total == 0) {
      onProgress?.call(0, 0);
    }
    return (
      added: total,
      skipped: skipped,
      message:
          'Import successful: $total items added, $skipped skipped (saved on this device)',
    );
  }
}
