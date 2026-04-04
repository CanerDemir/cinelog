import '../models/watchlist_item.dart';

enum WatchlistSort {
  dateNewest,
  dateOldest,
  titleAZ,
  ratingHigh,
}

List<WatchlistItem> applyWatchlistFilters(
  List<WatchlistItem> source, {
  required String searchQuery,
  required WatchlistSort sort,
  required String? genreFilter,
}) {
  var items = source.where((i) {
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      final inTitle = i.title.toLowerCase().contains(q);
      final inGenre = i.genre?.toLowerCase().contains(q) ?? false;
      if (!inTitle && !inGenre) return false;
    }
    if (genreFilter != null && genreFilter.trim().isNotEmpty) {
      final g = genreFilter.trim().toLowerCase();
      if (!(i.genre?.toLowerCase().contains(g) ?? false)) return false;
    }
    return true;
  }).toList();

  switch (sort) {
    case WatchlistSort.dateNewest:
      items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    case WatchlistSort.dateOldest:
      items.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    case WatchlistSort.titleAZ:
      items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    case WatchlistSort.ratingHigh:
      items.sort((a, b) {
        final ra = a.imdbRating ?? 0.0;
        final rb = b.imdbRating ?? 0.0;
        return rb.compareTo(ra);
      });
  }

  return items;
}
