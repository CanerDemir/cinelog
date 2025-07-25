import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../screens/add_item_screen.dart';

class WatchlistTile extends StatelessWidget {
  final WatchlistItem item;
  final VoidCallback onChanged;

  const WatchlistTile({
    super.key,
    required this.item,
    required this.onChanged,
  });
  
  Widget _buildTypeIndicator() {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.type == 'movie' ? Icons.movie_outlined : Icons.tv_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            item.type == 'movie' ? 'MOVIE' : 'TV',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(item: item),
            ),
          );
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster image or type indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                    ? Image.network(
                        item.posterUrl!,
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildTypeIndicator();
                        },
                      )
                    : _buildTypeIndicator(),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with watched status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: item.isWatched ? TextDecoration.lineThrough : null,
                              color: item.isWatched 
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                  : null,
                            ),
                          ),
                        ),
                        if (item.isWatched)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Watched',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Genre and year
                    if (item.genre != null || item.year != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          [
                            if (item.genre != null) item.genre!,
                            if (item.year != null) item.year.toString(),
                          ].join(' • '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Description
                    if (item.description != null)
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Rating and actions
                    Row(
                      children: [
                        if (item.isWatched && item.rating != null) ...[
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < item.rating! ? Icons.star : Icons.star_border,
                                size: 18,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          const Spacer(),
                        ] else
                          const Spacer(),
                        // Action buttons
                        if (!item.isWatched)
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              item.isWatched = true;
                              await item.save();
                              onChanged();
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Mark Watched'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        if (item.isWatched)
                          OutlinedButton.icon(
                            onPressed: () async {
                              item.isWatched = false;
                              item.rating = null;
                              await item.save();
                              onChanged();
                            },
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text('Unwatch'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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