import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../screens/movie_details_screen.dart';

class WatchlistTile extends StatelessWidget {
  final WatchlistItem item;
  final VoidCallback onChanged;
  final String contextId;

  const WatchlistTile({
    super.key,
    required this.item,
    required this.onChanged,
    this.contextId = 'default',
  });

  Widget _buildTypeIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A), // Fallback color
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.type == 'movie'
              ? [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ]
              : [
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.type == 'movie' ? Icons.movie_outlined : Icons.tv_outlined,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              item.type == 'movie' ? 'MOVIE' : 'TV',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = '${contextId}_poster_${item.dateAdded.toIso8601String()}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  item: item,
                  heroTag: heroTag,
                ),
              ),
            );
            onChanged();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poster Image (Expanded to fill available space)
              Expanded(
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                        ? Image.network(
                            item.posterUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildTypeIndicator();
                            },
                          )
                        : _buildTypeIndicator(),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating and Year Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (item.imdbRating != null || item.rating != null)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 12, color: Color(0xFFFF6B35)),
                              const SizedBox(width: 4),
                              Text(
                                item.imdbRating?.toStringAsFixed(1) ??
                                    (item.rating! * 2).toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                        // Year
                        if (item.year != null)
                          Text(
                            '${item.year}',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
