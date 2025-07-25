import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../services/storage_service.dart';
import 'add_item_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final WatchlistItem item;

  const MovieDetailsScreen({super.key, required this.item});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late WatchlistItem item;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    isBookmarked = item.isWatched;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Poster Image
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                ? Image.network(
                    item.posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackBackground();
                    },
                  )
                : _buildFallbackBackground(),
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
                // Top Bar with Close and Bookmark
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Bookmark Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                          onPressed: _toggleBookmark,
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
                      // IMDB Rating and Star Rating Row
                      Row(
                        children: [
                          // IMDB Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5C518),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'IMDB',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.imdbRating != null ? item.imdbRating!.toStringAsFixed(1) : 
                                  item.rating != null ? '${(item.rating! * 2).toStringAsFixed(1)}' : '6.8',
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
                          // Star Rating
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _getFormattedRating(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
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
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Edit Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _editItem,
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size(100, 40),
                                  textStyle: const TextStyle(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Remove Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _removeItem,
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size(100, 40),
                                  textStyle: const TextStyle(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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

  List<Widget> _buildGenreChips() {
    List<String> genres = [];
    
    if (item.genre != null) {
      genres = item.genre!.split(',').map((g) => g.trim()).toList();
    } else {
      // Default genres based on type
      genres = item.type == 'movie' 
          ? ['Action', 'Comedy', 'Superhero']
          : ['Drama', 'Sci-Fi', 'Action'];
    }

    return genres.map((genre) => Container(
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
    )).toList();
  }

  String _getDefaultDescription() {
    return "${item.title} is a ${item.year ?? 'recent'} ${item.type == 'movie' ? 'American film' : 'TV series'} "
           "${item.genre != null ? 'in the ${item.genre} genre' : 'featuring compelling storytelling'} "
           "that has captivated audiences worldwide. This ${item.type} offers an engaging experience "
           "with memorable characters and stunning visuals that make it a must-watch addition to your collection.";
  }
  
  String _getFormattedRating() {
    // Use IMDb data if available
    if (item.imdbRating != null) {
      final formattedVotes = _formatVoteCount(item.imdbVotes ?? 0);
      return '${item.imdbRating!.toStringAsFixed(1)} ($formattedVotes reviews)';
    }
    
    // Fall back to user rating if available
    if (item.rating != null) {
      return '${(item.rating! * 2).toStringAsFixed(1)} (Your rating)';
    }
    
    // Default value
    return '7.5 (Unknown reviews)';
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

  void _toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
      item.isWatched = isBookmarked;
    });
    
    if (isBookmarked && item.rating == null) {
      // If marking as watched for first time, ask for rating
      final rating = await _showRatingDialog();
      if (rating != null) {
        item.rating = rating;
      }
    }
    
    await StorageService.updateItem(item);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBookmarked 
                ? '${item.title} added to watchlist!' 
                : '${item.title} removed from watchlist!',
          ),
          backgroundColor: const Color(0xFFFF6B35),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _removeItem() async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed) {
      await StorageService.deleteItem(item);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from your watchlist'),
            backgroundColor: const Color(0xFFFF6B35),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _editItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: item),
      ),
    );
    
    // Refresh the screen when returning from edit
    setState(() {});
  }



  void _getReservation() async {
    if (!item.isWatched) {
      // Mark as watched and ask for rating
      final rating = await _showRatingDialog();
      if (rating != null) {
        setState(() {
          item.isWatched = true;
          item.rating = rating;
          isBookmarked = true;
        });
        await StorageService.updateItem(item);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.title} marked as watched and rated!'),
              backgroundColor: const Color(0xFFFF6B35),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      // Already watched, show options
      _showWatchedOptions();
    }
  }

  Future<int?> _showRatingDialog() async {
    int? selectedRating;
    
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rate this movie',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you rate this movie?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < (selectedRating ?? 0) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: selectedRating != null 
                ? () => Navigator.pop(context, selectedRating)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Rate'),
          ),
        ],
      ),
    );
  }

  void _showWatchedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Movie', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItemScreen(item: item),
                  ),
                );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Change Rating', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final rating = await _showRatingDialog();
                if (rating != null) {
                  setState(() {
                    item.rating = rating;
                  });
                  await StorageService.updateItem(item);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove from Watchlist', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation();
                if (confirmed) {
                  await StorageService.deleteItem(item);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Movie', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${item.title}" from your watchlist?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    ) ?? false;
  }
}