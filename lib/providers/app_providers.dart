import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../catalog/watchlist_filters.dart';
import '../models/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

const _guestModeKey = 'guest_mode';

/// Guest mode: watchlist stays on device (Hive) only.
final guestModeProvider = AsyncNotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);

class GuestModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_guestModeKey) ?? false;
  }

  Future<void> setGuest(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_guestModeKey, value);
    // Update state in place — avoid invalidateSelf() here, which re-runs [build]
    // while [watchlistRepositoryProvider] is already watching this provider and
    // can trigger Riverpod's CircularDependencyException after login.
    state = AsyncData(value);
    ref.invalidate(watchlistRepositoryProvider);
    ref.invalidate(watchlistStreamProvider);
  }
}

/// Firebase auth state (registered users).
final firebaseAuthUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Repository for current session: Hive when guest, else Firebase when signed in.
final watchlistRepositoryProvider = Provider<WatchlistRepository?>((ref) {
  final guestAsync = ref.watch(guestModeProvider);
  final guest = guestAsync.valueOrNull ?? false;
  if (guestAsync.isLoading) return null;
  if (guest) {
    return HiveWatchlistRepository();
  }
  final user = ref.watch(firebaseAuthUserProvider).valueOrNull;
  if (user == null) return null;
  return FirebaseWatchlistRepository();
});

/// Live list for home and overlays.
final watchlistStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final repo = ref.watch(watchlistRepositoryProvider);
  if (repo == null) {
    return Stream.value(const <WatchlistItem>[]);
  }
  return repo.watchItems();
});

final watchlistSortProvider =
    StateProvider<WatchlistSort>((ref) => WatchlistSort.dateNewest);

final watchlistGenreFilterProvider = StateProvider<String?>((ref) => null);
