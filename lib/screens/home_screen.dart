import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../services/storage_service.dart';
import '../services/data_service.dart';
import 'add_item_screen.dart';
import 'category_list_screen.dart';
import '../widgets/watchlist_tile.dart';
import '../widgets/cinelog_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WatchlistItem> _allItems = [];
  String _searchQuery = '';
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _allItems = StorageService.getAllItems();
    });
  }

  List<WatchlistItem> get _filteredItems {
    var items = _allItems;

    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.genre?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    return items;
  }

  List<WatchlistItem> get _latestMovies {
    return _allItems.where((item) => item.type == 'movie').toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _latestTVSeries {
    return _allItems.where((item) => item.type == 'tv').toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _notWatchedMovies {
    return _allItems
        .where((item) => item.type == 'movie' && !item.isWatched)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _watchedMovies {
    return _allItems
        .where((item) => item.type == 'movie' && item.isWatched)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _notWatchedTVSeries {
    return _allItems
        .where((item) => item.type == 'tv' && !item.isWatched)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _watchedTVSeries {
    return _allItems
        .where((item) => item.type == 'tv' && item.isWatched)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _favoriteItems {
    return _allItems.where((item) => item.isFavorite).toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _favoriteMovies {
    return _allItems
        .where((item) => item.type == 'movie' && item.isFavorite)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _favoriteTVSeries {
    return _allItems
        .where((item) => item.type == 'tv' && item.isFavorite)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _watchlistItems {
    return _allItems.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content - Full screen
            IndexedStack(
              index: _selectedBottomNavIndex,
              children: [
                _buildMoviesTab(),
                _buildTVSeriesTab(),
                _buildBookmarksTab(),
                _buildFavoritesTab(),
              ],
            ),
            // CineLog Logo - Floating overlay
            Positioned(
              top: 16,
              left: 16,
              right:
                  16, // const EdgeInsets.all(16) would be cleaner but maintaining structure
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF1A1D29).withValues(alpha: 0.9),
                          const Color(0xFF1A1D29).withValues(alpha: 0.7),
                          const Color(0xFF1A1D29).withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.only(right: 16, bottom: 8),
                    child: _buildCineLogLogo(),
                  ),

                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3A).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Color(0xFF6B7280)),
                          prefixIcon: Icon(Icons.search,
                              color: Color(0xFF6B7280), size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0), // Centering text vertically
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Settings / Menu Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D3A).withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF2A2D3A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async {
                        if (value == 'export') {
                          final result = await DataService.exportData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor:
                                    result.startsWith('Export successful')
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          }
                        } else if (value == 'import') {
                          final result = await DataService.importData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor:
                                    result.startsWith('Import successful')
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                            if (result.startsWith('Import successful')) {
                              _loadItems(); // Refresh the list
                            }
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'export',
                          child: Row(
                            children: [
                              Icon(Icons.upload_file,
                                  color: Colors.white70, size: 20),
                              SizedBox(width: 12),
                              Text('Export JSON',
                                  style: TextStyle(color: Colors.white)),
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
                                  style: TextStyle(color: Colors.white)),
                            ],
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
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D29),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2D3A), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.movie_outlined, 'Movie', 0),
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
          _loadItems();
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCineLogLogo() {
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive logo sizing based on screen width
      final screenWidth = MediaQuery.of(context).size.width;

      // Calculate logo size:
      // - Minimum size of 40 for very small screens
      // - Maximum size of 60 for large screens
      // - Otherwise 12% of screen width
      // final logoSize = screenWidth * 0.12.clamp(40.0 / screenWidth, 60.0 / screenWidth);
      final logoSize = 40.0;

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

  Widget _buildMoviesTab() {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
                height: 90), // Space for floating logo + extra top padding

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
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
                  Tab(text: 'Not Watched'),
                  Tab(text: 'Watched'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildVerticalMovieList(
                      _notWatchedMovies,
                      'No unwatched movies yet',
                      'movies_not_watched',
                      'Add Movie'),
                  _buildVerticalMovieList(_watchedMovies,
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
      // Use existing empty section but adapt it or create simple center text
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined,
                size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddItemScreen()),
                );
                _loadItems();
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
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // Adjust based on card height/width ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WatchlistTile(
          item: item,
          onChanged: _loadItems,
          contextId: contextId,
        );
      },
    );
  }

  Widget _buildTVSeriesTab() {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
                height: 90), // Space for floating logo + extra top padding

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
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
                  Tab(text: 'Not Watched'),
                  Tab(text: 'Watched'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildVerticalMovieList(
                      _notWatchedTVSeries,
                      'No unwatched TV series yet',
                      'tv_not_watched',
                      'Add TV Series'),
                  _buildVerticalMovieList(
                      _watchedTVSeries,
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

  Widget _buildBookmarksTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(
              height: 90), // Space for floating logo + extra top padding

          // All Items List
          Expanded(
            child: _buildVerticalMovieList(_watchlistItems,
                'No items in watchlist yet', 'watchlist_all', 'Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
                height: 90), // Space for floating logo + extra top padding

            // Tab Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
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
                  _buildVerticalMovieList(_favoriteMovies,
                      'No favorite movies yet', 'fav_movies', 'Add Movie'),
                  _buildVerticalMovieList(_favoriteTVSeries,
                      'No favorite TV series yet', 'fav_tv', 'Add TV Series'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
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

  Widget _buildViewAllButton(String title, List<WatchlistItem> items) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              title: title,
              items: items,
            ),
          ),
        );
      },
      child: const Text(
        'View all',
        style: TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
