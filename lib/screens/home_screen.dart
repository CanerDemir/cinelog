import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../services/storage_service.dart';
import 'add_item_screen.dart';
import 'movie_details_screen.dart';
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
  final List<String> _categories = ['Action', 'Comedy', 'Romance', 'Drama', 'Thriller', 'Sci-Fi'];

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
      items = items.where((item) =>
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.genre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return items;
  }

  List<WatchlistItem> get _latestMovies {
    return _allItems
        .where((item) => item.type == 'movie')
        .toList()
        ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  List<WatchlistItem> get _latestTVSeries {
    return _allItems
        .where((item) => item.type == 'tv')
        .toList()
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
    return _allItems
        .where((item) => item.isFavorite)
        .toList()
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
    return _allItems
        .toList()
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF1A1D29).withOpacity(0.9),
                      const Color(0xFF1A1D29).withOpacity(0.7),
                      const Color(0xFF1A1D29).withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                padding: const EdgeInsets.only(right: 40, bottom: 8),
                child: _buildCineLogLogo(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive logo sizing based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Calculate logo size: 
        // - Minimum size of 40 for very small screens
        // - Maximum size of 60 for large screens
        // - Otherwise 12% of screen width
        final logoSize = screenWidth * 0.12.clamp(40.0 / screenWidth, 60.0 / screenWidth);
        
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
      }
    );
  }

  Widget _buildMoviesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Space for floating logo
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search movie ....',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to categories view
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Categories Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Not Watched Movies Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Not Watched Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildViewAllButton('Not Watched Movies', _notWatchedMovies),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Not Watched Movies List - Two Rows
            _buildTwoRowMovieList(_notWatchedMovies, 'No unwatched movies yet', showAddButton: false),
            
            const SizedBox(height: 30),
            
            // Watched Movies Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Watched Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildViewAllButton('Watched Movies', _watchedMovies),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Watched Movies List - Two Rows
            _buildTwoRowMovieList(_watchedMovies, 'No watched movies yet', showAddButton: false),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTVSeriesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Space for floating logo
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search TV series ....',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to categories view
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Categories Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Not Watched TV Series Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Not Watched TV Series',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all not watched TV series
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Not Watched TV Series List - Two Rows
            _buildTwoRowMovieList(_notWatchedTVSeries, 'No unwatched TV series yet', showAddButton: false),
            
            const SizedBox(height: 30),
            
            // Watched TV Series Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Watched TV Series',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to watched TV series
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Watched TV Series List - Two Rows
            _buildTwoRowMovieList(_watchedTVSeries, 'No watched TV series yet', showAddButton: false),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Space for floating logo
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search watchlist ...',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // All Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all items
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // All Items List - Two Rows
            _buildTwoRowMovieList(_allItems, 'No items in watchlist yet', showAddButton: false),
            
            const SizedBox(height: 30),
            
            // Recently Added Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Added',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to recently added
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recently Added List - Two Rows
            _buildTwoRowMovieList(_allItems, 'No items yet', showAddButton: false),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
  
  Widget _buildFavoritesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Space for floating logo
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search favorites ...',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Favorite Movies Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favorite Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all favorite movies
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Favorite Movies List - Two Rows
            _buildTwoRowMovieList(_favoriteMovies, 'No favorite movies yet', showAddButton: false),
            
            const SizedBox(height: 30),
            
            // Favorite TV Series Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favorite TV Series',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all favorite TV series
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Favorite TV Series List - Two Rows
            _buildTwoRowMovieList(_favoriteTVSeries, 'No favorite TV series yet', showAddButton: false),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTwoRowMovieList(List<WatchlistItem> items, String emptyMessage, {bool showAddButton = true}) {
    if (items.isEmpty) {
      return _buildEmptyMovieSection(emptyMessage, showAddButton: showAddButton);
    }
    
    // Calculate how many items to show (up to 20 items, 10 per row)
    final itemCount = items.length > 20 ? 20 : items.length;
    final itemsPerRow = (itemCount / 2).ceil(); // Items in first row
    
    return SizedBox(
      height: 450, // Adjusted height for two rows
      child: Column(
        children: [
          // First Row
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemsPerRow,
              itemBuilder: (context, index) {
                return _buildMovieCard(items[index]);
              },
            ),
          ),
          const SizedBox(height: 12), // Reduced space between rows
          // Second Row (if there are enough items)
          if (itemCount > itemsPerRow)
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount - itemsPerRow,
                itemBuilder: (context, index) {
                  return _buildMovieCard(items[itemsPerRow + index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(WatchlistItem item) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(item: item),
          ),
        );
        _loadItems();
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Container(
              height: 200, // Reduced height to fix overflow
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF2A2D3A),
              ),
              child: Stack(
                children: [
                  // Poster Image or Fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                        ? Image.network(
                            item.posterUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackPoster(item);
                            },
                          )
                        : _buildFallbackPoster(item),
                  ),
                  // Watched indicator
                  if (item.isWatched)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  // Favorite heart icon
                  Positioned(
                    top: 8,
                    right: item.isWatched ? 40 : 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          item.isFavorite = !item.isFavorite;
                          StorageService.updateItem(item);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: item.isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  if (item.rating != null && item.rating! > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.rating}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPoster(WatchlistItem item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.type == 'movie' ? Icons.movie : Icons.tv,
            size: 40,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            item.genre ?? (item.type == 'movie' ? 'Movie' : 'TV Series'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMovieSection(String message, {bool showAddButton = true}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          if (showAddButton) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
                _loadItems();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Movie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
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
            color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF6B7280),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF6B7280),
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
