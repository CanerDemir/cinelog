import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/watchlist_item.dart';
import '../providers/app_providers.dart';
import '../services/movie_search_service.dart';
import '../util/app_log.dart';
import '../theme/cinematic_tokens.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  static const _accent = CinematicTokens.primaryContainer;
  static const _card = CinematicTokens.panel;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _posterUrlController = TextEditingController();

  bool _isWatched = false;
  bool _isFavorite = false;

  List<MovieSearchResult> _searchResults = [];
  bool _isSearching = false;
  MovieSearchResult? _selectedMovie;
  Timer? _titleSearchDebounce;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Add New Content',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: _buildAddFormScroll(context),
      ),
    );
  }

  Widget _buildAddFormScroll(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'SEARCH FOR MOVIE OR SERIES TITLE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: _accent.withValues(alpha: 0.95),
          ),
        ),
        const SizedBox(height: 10),
        _buildAddSearchField(context),
        if (_selectedMovie != null) ...[
          const SizedBox(height: 28),
          _buildSectionDivider('SELECTED PREVIEW'),
          const SizedBox(height: 16),
          _buildSelectedPreviewCard(context),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _clearSelection,
              child: Text(
                'Change selection',
                style: TextStyle(
                  color: _accent.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDesignToggleRow(
            icon: Icons.favorite_rounded,
            iconBackground: const Color(0xFFE53935),
            title: 'Favorite?',
            subtitle: 'ADD TO YOUR HIGHLIGHTS',
            value: _isFavorite,
            activeThumbColor: _accent,
            onChanged: (v) => setState(() => _isFavorite = v),
          ),
          const SizedBox(height: 12),
          _buildDesignToggleRow(
            icon: Icons.check_rounded,
            iconBackground: const Color(0xFF42A5F5),
            title: 'Watched?',
            subtitle: 'MARK AS FINISHED',
            value: _isWatched,
            activeThumbColor: const Color(0xFF42A5F5),
            onChanged: (v) {
              setState(() => _isWatched = v);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _saveItem,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Content'),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: CinematicTokens.onPrimaryFixed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 32),
          Text(
            'Type a title and choose a result to see details and save.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedMovie = null;
      _searchResults = [];
      _titleController.clear();
      _descriptionController.clear();
      _genreController.clear();
      _yearController.clear();
      _posterUrlController.clear();
    });
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
      ],
    );
  }

  Widget _buildDesignToggleRow({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeThumbColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return activeThumbColor ?? _accent;
              }
              return Colors.grey.shade400;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return (activeThumbColor ?? _accent).withValues(alpha: 0.45);
              }
              return Colors.grey.shade700;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSearchField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: _card.withValues(alpha: 0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onTitleSearchChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        if (_searchResults.isNotEmpty && _selectedMovie == null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: result.posterPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: result.fullPosterUrl,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 40,
                              height: 60,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.image_not_supported,
                                  size: 20),
                            ),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 60,
                          color: Colors.grey.shade800,
                          child: Icon(
                            result.mediaType == 'movie'
                                ? Icons.movie
                                : Icons.tv,
                            color: Colors.white,
                          ),
                        ),
                  title: Text(
                    result.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${result.year ?? 'Unknown'} • ${result.mediaType == 'movie' ? 'Movie' : 'TV Series'}',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  onTap: () => _selectMovie(result),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedPreviewCard(BuildContext context) {
    final m = _selectedMovie!;
    final ratingText = m.imdbData != null
        ? m.imdbData!.rating.toStringAsFixed(1)
        : m.voteAverage?.toStringAsFixed(1);
    final overview = (m.overview ?? '').trim();
    final snippet = overview.length > 140 ? '${overview.substring(0, 140)}…' : overview;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: m.posterPath != null && m.fullPosterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: m.fullPosterUrl,
                    width: 88,
                    height: 132,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 88,
                      height: 132,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie_outlined, size: 40),
                    ),
                  )
                : Container(
                    width: 88,
                    height: 132,
                    color: Colors.grey.shade800,
                    child: Icon(
                      m.mediaType == 'movie'
                          ? Icons.movie_outlined
                          : Icons.tv_outlined,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (m.year != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${m.year}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (m.genres.isNotEmpty)
                      Text(
                        m.genres.join(', '),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    if (ratingText != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: _accent, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            ratingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (snippet.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveItem() async {
    if (_selectedMovie == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Select a movie or series from the search results first.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final m = _selectedMovie!;
    final title = _titleController.text.trim().isEmpty
        ? m.title
        : _titleController.text.trim();
    final desc = (m.overview ?? '').trim();
    final item = WatchlistItem(
      title: title,
      type: m.mediaType,
      description: desc.isEmpty ? null : desc,
      genre: m.genres.isEmpty ? null : m.genres.join(', '),
      year: m.year,
      isWatched: _isWatched,
      dateAdded: DateTime.now(),
      rating: null,
      posterUrl: m.fullPosterUrl.isEmpty ? null : m.fullPosterUrl,
      isFavorite: _isFavorite,
      imdbRating: m.imdbData?.rating ?? m.voteAverage,
      imdbVotes: m.imdbData?.voteCount,
      imdbId: m.imdbData?.imdbId,
    );

    final repo = ref.read(watchlistRepositoryProvider);
    if (repo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage is not ready. Try again in a moment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    await repo.addItem(item);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onTitleSearchChanged(String query) {
    _titleSearchDebounce?.cancel();
    _titleSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _searchMovies(query);
      }
    });
  }

  Future<void> _searchMovies(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await MovieSearchService.searchMulti(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      appLog('Error searching movies: $e');
    }
  }

  Future<void> _selectMovie(MovieSearchResult movie) async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final details =
          await MovieSearchService.getDetails(movie.id, movie.mediaType);

      if (details != null) {
        setState(() {
          _selectedMovie = details;
          _titleController.text = details.title;
          _descriptionController.text = details.overview ?? '';
          _genreController.text = details.genres.join(', ');
          if (details.year != null) {
            _yearController.text = details.year.toString();
          }
          _posterUrlController.text = details.fullPosterUrl;

          // Display IMDb data if available
          if (details.imdbData != null) {
            appLog(
                'IMDb data found: ${details.imdbData!.rating} (${details.imdbData!.voteCount} votes)');
          }
        });
      }
    } catch (e) {
      appLog('Error getting movie details: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _titleSearchDebounce?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }
}
