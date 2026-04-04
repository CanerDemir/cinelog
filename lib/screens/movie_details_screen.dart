import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/watchlist_item.dart';
import '../providers/app_providers.dart';
import '../repositories/watchlist_repository.dart';
import '../services/imdb_service.dart';
import '../theme/cinematic_tokens.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  final WatchlistItem item;
  final String? heroTag;

  const MovieDetailsScreen({
    super.key,
    required this.item,
    this.heroTag,
  });

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  late WatchlistItem item;
  Future<IMDbData?>? _imdbDataFuture;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    _refreshOmdbFuture();
  }

  void _refreshOmdbFuture() {
    _imdbDataFuture = IMDbService.getIMDbDataByTitle(
      item.title,
      year: item.year?.toString(),
      mediaType: item.type,
    );
  }

  WatchlistRepository? _repoOrNull() => ref.read(watchlistRepositoryProvider);

  void _showRepoNotReady() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage is not ready. Try again in a moment.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Poster Image
          Hero(
            tag: widget.heroTag ?? 'poster_${item.dateAdded.toIso8601String()}',
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.posterUrl!,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, url) => _buildFallbackBackground(),
                      errorWidget: (context, url, error) =>
                          _buildFallbackBackground(),
                    )
                  : _buildFallbackBackground(),
            ),
          ),

          // Gradient Overlay
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar: close, favorite, watched
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Close',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            item.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item.isFavorite
                                ? CinematicTokens.primaryContainer
                                : Colors.white,
                          ),
                          onPressed: _toggleFavorite,
                          tooltip: 'Favorite',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            item.isWatched
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: Colors.white,
                          ),
                          onPressed: _toggleWatched,
                          tooltip: 'Watched',
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer for center area
                const Expanded(
                  child: SizedBox(),
                ),

                // Bottom Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingSection(),

                      const SizedBox(height: 16),

                      // Movie Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Genre Chips
                      Wrap(
                        spacing: 8,
                        children: _buildGenreChips(),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        item.description ?? _getDefaultDescription(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // Actors and Year
                      FutureBuilder<IMDbData?>(
                        future: _imdbDataFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            // Fallback if no data or loading
                            if (item.year != null) {
                              return Text(
                                'Year: ${item.year}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final data = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.year != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Year: ${data.year}',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (data.actors != null)
                                Text(
                                  'Cast: ${data.actors}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Remove
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _removeItem,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.type == 'movie'
                ? const Color(0xFF6366F1).withOpacity(0.8)
                : const Color(0xFF10B981).withOpacity(0.8),
            item.type == 'movie'
                ? const Color(0xFF8B5CF6).withOpacity(0.6)
                : const Color(0xFF059669).withOpacity(0.6),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          item.type == 'movie' ? Icons.movie : Icons.tv,
          size: 120,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.imdbRating != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C518),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'IMDb',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.imdbRating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (item.imdbVotes ?? 0) <= 0
                      ? 'Score from OMDb / IMDb'
                      : '${_formatVoteCount(item.imdbVotes ?? 0)} IMDb votes',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Widget> _buildGenreChips() {
    if (item.genre == null || item.genre!.trim().isEmpty) {
      return [];
    }
    final genres = item.genre!
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
    if (genres.isEmpty) return [];

    return genres
        .map((genre) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                genre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
        .toList();
  }

  String _getDefaultDescription() {
    return "${item.title} is a ${item.year ?? 'recent'} ${item.type == 'movie' ? 'American film' : 'TV series'} "
        "${item.genre != null ? 'in the ${item.genre} genre' : 'featuring compelling storytelling'} "
        "that has captivated audiences worldwide. This ${item.type} offers an engaging experience "
        "with memorable characters and stunning visuals that make it a must-watch addition to your collection.";
  }

  String _formatVoteCount(int votes) {
    if (votes >= 1000000) {
      return '${(votes / 1000000).toStringAsFixed(1)}M';
    } else if (votes >= 1000) {
      return '${(votes / 1000).toStringAsFixed(1)}K';
    } else {
      return votes.toString();
    }
  }

  Future<void> _toggleFavorite() async {
    final repo = _repoOrNull();
    if (repo == null) {
      _showRepoNotReady();
      return;
    }
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
    await repo.updateItem(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        backgroundColor: CinematicTokens.primaryContainer,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleWatched() async {
    final repo = _repoOrNull();
    if (repo == null) {
      _showRepoNotReady();
      return;
    }
    setState(() {
      item.isWatched = !item.isWatched;
    });
    await repo.updateItem(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isWatched
              ? '${item.title} marked as watched'
              : '${item.title} marked as not watched',
        ),
        backgroundColor: CinematicTokens.primaryContainer,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeItem() async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed) {
      final repo = _repoOrNull();
      if (repo == null) {
        _showRepoNotReady();
        return;
      }
      await repo.deleteItem(item);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from your watchlist'),
            backgroundColor: CinematicTokens.primaryContainer,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: CinematicTokens.panel,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              item.type == 'tv' ? 'Remove series' : 'Remove movie',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to remove "${item.title}" from your watchlist?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
