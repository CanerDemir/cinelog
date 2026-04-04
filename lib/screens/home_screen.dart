import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/watchlist_filters.dart';
import '../models/watchlist_item.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'add_item_screen.dart';
import '../widgets/watchlist_tile.dart';
import '../widgets/cinelog_logo.dart';
import '../widgets/import_progress_overlay.dart';
import '../theme/cinematic_tokens.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBottomNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final AnimationController _searchAnimController;
  late final Animation<double> _searchExpandAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 0,
    );
    _searchExpandAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_searchAnimController.isCompleted) {
      _searchAnimController.reverse();
      _searchFocusNode.unfocus();
    } else {
      _searchAnimController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
  }

  Future<void> _refreshList() async {
    ref.invalidate(watchlistStreamProvider);
  }

  List<WatchlistItem> _baseFiltered(List<WatchlistItem> all) {
    return applyWatchlistFilters(
      all,
      searchQuery: _searchController.text,
      sort: ref.watch(watchlistSortProvider),
      genreFilter: ref.watch(watchlistGenreFilterProvider),
    );
  }

  Future<void> _importWatchlistJson() async {
    final repo = ref.read(watchlistRepositoryProvider);
    if (repo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage is not ready. Try again in a moment.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? jsonString;
    try {
      jsonString = await DataService.pickAndReadImportJsonFile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted || jsonString == null) return;

    final progress = ValueNotifier<ImportProgress?>(null);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useRootNavigator: true,
      builder: (_) => ImportProgressOverlay(progressListenable: progress),
    );

    String result;
    try {
      result = await DataService.importJsonWithRepository(
        jsonString,
        repo,
        onProgress: (done, total) {
          progress.value = ImportProgress(done: done, total: total);
        },
      );
    } catch (e) {
      result = 'Import failed: $e';
    } finally {
      progress.dispose();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!mounted) return;
    final ok = result.startsWith('Import successful');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  List<WatchlistItem> _notWatchedMovies(List<WatchlistItem> base) {
    return base
        .where((item) => item.type == 'movie' && !item.isWatched)
        .toList();
  }

  List<WatchlistItem> _watchedMovies(List<WatchlistItem> base) {
    return base
        .where((item) => item.type == 'movie' && item.isWatched)
        .toList();
  }

  List<WatchlistItem> _notWatchedTVSeries(List<WatchlistItem> base) {
    return base.where((item) => item.type == 'tv' && !item.isWatched).toList();
  }

  List<WatchlistItem> _watchedTVSeries(List<WatchlistItem> base) {
    return base.where((item) => item.type == 'tv' && item.isWatched).toList();
  }

  List<WatchlistItem> _favoriteMovies(List<WatchlistItem> base) {
    return base
        .where((item) => item.type == 'movie' && item.isFavorite)
        .toList();
  }

  List<WatchlistItem> _favoriteTVSeries(List<WatchlistItem> base) {
    return base.where((item) => item.type == 'tv' && item.isFavorite).toList();
  }

  List<WatchlistItem> _watchlistItems(List<WatchlistItem> base) => base;

  void _showSortFilterSheet() {
    final genreTc = TextEditingController(
        text: ref.read(watchlistGenreFilterProvider) ?? '');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CinematicTokens.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sort & filter',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text('Sort by',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WatchlistSort.values.map((s) {
                    final selected = ref.read(watchlistSortProvider) == s;
                    return FilterChip(
                      label: Text(_sortLabel(s)),
                      selected: selected,
                      onSelected: (_) {
                        ref.read(watchlistSortProvider.notifier).state = s;
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genreTc,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Genre contains',
                    labelStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    hintText: 'e.g. Drama',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                    filled: true,
                    fillColor: CinematicTokens.pageBackground,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (v) {
                    ref.read(watchlistGenreFilterProvider.notifier).state =
                        v.trim().isEmpty ? null : v.trim();
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final v = genreTc.text;
                    ref.read(watchlistGenreFilterProvider.notifier).state =
                        v.trim().isEmpty ? null : v.trim();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply genre filter'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ref.read(watchlistGenreFilterProvider.notifier).state =
                          null;
                      ref.read(watchlistSortProvider.notifier).state =
                          WatchlistSort.dateNewest;
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(genreTc.dispose);
  }

  String _sortLabel(WatchlistSort s) {
    switch (s) {
      case WatchlistSort.dateNewest:
        return 'Date (newest)';
      case WatchlistSort.dateOldest:
        return 'Date (oldest)';
      case WatchlistSort.titleAZ:
        return 'Title A–Z';
      case WatchlistSort.ratingHigh:
        return 'Rating';
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(watchlistStreamProvider);
    final guestAsync = ref.watch(guestModeProvider);
    final isGuest = guestAsync.valueOrNull ?? false;

    return asyncItems.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
              color: CinematicTokens.primaryContainer),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load your watchlist. Check your connection and try pull-to-refresh.\n\n(${e.runtimeType})',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
      data: (all) {
        final base = _baseFiltered(all);
        final headerInset = isGuest ? 132.0 : 96.0;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IndexedStack(
                  index: _selectedBottomNavIndex,
                  children: [
                    _buildMoviesTab(base, headerInset),
                    _buildTVSeriesTab(base, headerInset),
                    _buildBookmarksTab(base, headerInset),
                    _buildFavoritesTab(base, headerInset),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  CinematicTokens.pageBackground
                                      .withValues(alpha: 0.9),
                                  CinematicTokens.pageBackground
                                      .withValues(alpha: 0.7),
                                  CinematicTokens.pageBackground
                                      .withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                            ),
                            padding:
                                const EdgeInsets.only(right: 16, bottom: 8),
                            child: _buildCineLogLogo(),
                          ),

                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxW = constraints.maxWidth;
                                return AnimatedBuilder(
                                  animation: _searchExpandAnimation,
                                  builder: (context, _) {
                                    final t =
                                        _searchExpandAnimation.value.clamp(
                                      0.0,
                                      1.0,
                                    );
                                    if (t < 0.001) {
                                      return const SizedBox(
                                        width: 0,
                                        height: 40,
                                      );
                                    }
                                    final barW = maxW * t;
                                    return ClipRect(
                                      child: SizedBox(
                                        width: barW,
                                        height: 40,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            width: maxW,
                                            height: 40,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: CinematicTokens.panel
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.1),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: TextField(
                                                  controller: _searchController,
                                                  focusNode: _searchFocusNode,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Search...',
                                                    hintStyle: const TextStyle(
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                    suffixIcon:
                                                        _searchController
                                                                .text.isEmpty
                                                            ? null
                                                            : IconButton(
                                                                visualDensity:
                                                                    VisualDensity
                                                                        .compact,
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .clear_rounded,
                                                                  color: Color(
                                                                      0xFF6B7280),
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  _searchController
                                                                      .clear();
                                                                  setState(
                                                                      () {});
                                                                },
                                                              ),
                                                  ),
                                                  onChanged: (_) =>
                                                      setState(() {}),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          Tooltip(
                            message: 'Search',
                            child: Material(
                              color:
                                  CinematicTokens.panel.withValues(alpha: 0.8),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _toggleSearch,
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: ListenableBuilder(
                                      listenable: _searchAnimController,
                                      builder: (context, _) {
                                        final open =
                                            _searchAnimController.value > 0.5;
                                        return Icon(
                                          open
                                              ? Icons.close_rounded
                                              : Icons.search_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Tooltip(
                            message: 'Sort and filter',
                            child: Material(
                              color:
                                  CinematicTokens.panel.withValues(alpha: 0.8),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _showSortFilterSheet,
                                child: const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Icon(Icons.tune_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Settings / Menu Button
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  CinematicTokens.panel.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              color: CinematicTokens.panel,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) async {
                                if (value == 'signout') {
                                  if (isGuest) {
                                    await ref
                                        .read(guestModeProvider.notifier)
                                        .setGuest(false);
                                  } else {
                                    await AuthService.signOut();
                                  }
                                } else if (value == 'export') {
                                  final result =
                                      await DataService.exportItems(all);
                                  if (context.mounted) {
                                    final ok = result
                                            .startsWith('Export successful') ||
                                        result == 'Export download started';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result),
                                        backgroundColor:
                                            ok ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                } else if (value == 'import') {
                                  await _importWatchlistJson();
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'signout',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout,
                                          color: Colors.white70, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        isGuest
                                            ? 'Exit guest mode'
                                            : 'Sign out',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem<String>(
                                  value: 'export',
                                  child: Row(
                                    children: [
                                      Icon(Icons.upload_file,
                                          color: Colors.white70, size: 20),
                                      SizedBox(width: 12),
                                      Text('Export JSON',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'import',
                                  child: Row(
                                    children: [
                                      Icon(Icons.download,
                                          color: Colors.white70, size: 20),
                                      SizedBox(width: 12),
                                      Text('Import JSON',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isGuest)
                        Semantics(
                          container: true,
                          label:
                              'Guest mode. Your watchlist is stored only on this device.',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Material(
                              color: CinematicTokens.panel,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Guest mode: your list stays on this device only. '
                                  'Sign in with email to sync to the cloud.',
                                  style: TextStyle(
                                    color: Colors.amber.shade200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(255, 107, 53, 0.1),
                              width: 1,
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
          bottomNavigationBar: Container(
            height: 80,
            decoration: BoxDecoration(
              color: CinematicTokens.pageBackground,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.movie_outlined, 'Movies', 0),
                _buildBottomNavItem(Icons.tv_outlined, 'TV Series', 1),
                _buildBottomNavItem(Icons.bookmark_outline, 'Watchlist', 2),
                _buildBottomNavItem(Icons.favorite_outline, 'Favorites', 3),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );
              await _refreshList();
            },
            backgroundColor: CinematicTokens.primaryContainer,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFFFF6B35) : const Color(0xFF6B7280),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCineLogLogo() {
    return LayoutBuilder(builder: (context, constraints) {
      // responsive resize logic commented out as logoSize is fixed
      const logoSize = 40.0;

      // Container height is slightly larger than logo for padding
      final containerHeight = logoSize + 10;

      return SizedBox(
        height: containerHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CineLogLogo(size: logoSize),
          ),
        ),
      );
    });
  }

  Widget _buildMoviesTab(List<WatchlistItem> base, double headerInset) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: headerInset),

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: CinematicTokens.panel,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'To Watch'),
                    Tab(text: 'Watched'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildVerticalMovieList(
                      _notWatchedMovies(base),
                      'No unwatched movies yet',
                      'movies_not_watched',
                      'Add Movie'),
                  _buildVerticalMovieList(_watchedMovies(base),
                      'No watched movies yet', 'movies_watched', 'Add Movie'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalMovieList(
      List<WatchlistItem> items, String emptyMessage, String contextId,
      [String addButtonLabel = 'Add Movie']) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFFF6B35),
        onRefresh: _refreshList,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_creation_outlined,
                        size: 64, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      emptyMessage,
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddItemScreen()),
                        );
                        await _refreshList();
                      },
                      icon: const Icon(Icons.add),
                      label: Text(addButtonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF6B35),
      onRefresh: _refreshList,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return WatchlistTile(
            item: item,
            onChanged: () {
              _refreshList();
            },
            contextId: contextId,
          );
        },
      ),
    );
  }

  Widget _buildTVSeriesTab(List<WatchlistItem> base, double headerInset) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: headerInset),

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: CinematicTokens.panel,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'To Watch'),
                    Tab(text: 'Watched'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildVerticalMovieList(
                      _notWatchedTVSeries(base),
                      'No unwatched TV series yet',
                      'tv_not_watched',
                      'Add TV Series'),
                  _buildVerticalMovieList(
                      _watchedTVSeries(base),
                      'No watched TV series yet',
                      'tv_watched',
                      'Add TV Series'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksTab(List<WatchlistItem> base, double headerInset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: headerInset),

          // All Items List
          Expanded(
            child: _buildVerticalMovieList(_watchlistItems(base),
                'No items in watchlist yet', 'watchlist_all', 'Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(List<WatchlistItem> base, double headerInset) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: headerInset),

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: CinematicTokens.panel,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Movies'),
                  Tab(text: 'TV Series'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildVerticalMovieList(_favoriteMovies(base),
                      'No favorite movies yet', 'fav_movies', 'Add Movie'),
                  _buildVerticalMovieList(_favoriteTVSeries(base),
                      'No favorite TV series yet', 'fav_tv', 'Add TV Series'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
