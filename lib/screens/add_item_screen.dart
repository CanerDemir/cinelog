import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../services/storage_service.dart';
import '../services/movie_search_service.dart';

class AddItemScreen extends StatefulWidget {
  final WatchlistItem? item;

  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _posterUrlController = TextEditingController();
  
  String _selectedType = 'movie';
  bool _isWatched = false;
  int? _rating;
  
  List<MovieSearchResult> _searchResults = [];
  bool _isSearching = false;
  MovieSearchResult? _selectedMovie;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description ?? '';
      _genreController.text = widget.item!.genre ?? '';
      _yearController.text = widget.item!.year?.toString() ?? '';
      _posterUrlController.text = widget.item!.posterUrl ?? '';
      _selectedType = widget.item!.type;
      _isWatched = widget.item!.isWatched;
      _rating = widget.item!.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        foregroundColor: Colors.white,
        title: Text(
          isEditing ? 'Edit Movie' : 'Add New Movie',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B35)),
              onPressed: _deleteItem,
              tooltip: 'Delete item',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Your Item' : 'Add New Item',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing 
                              ? 'Update the details of your watchlist item'
                              : 'Add a movie or TV series to your watchlist',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Form fields
            _buildFormSection(
              title: 'Basic Information',
              children: [
                _buildTitleAutocomplete(),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'movie',
                      child: Row(
                        children: [
                          Icon(Icons.movie_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Movie'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'tv',
                      child: Row(
                        children: [
                          Icon(Icons.tv_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('TV Series'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildFormSection(
              title: 'Details',
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description or plot summary',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _genreController,
                        decoration: const InputDecoration(
                          labelText: 'Genre',
                          hintText: 'Action, Drama, Comedy...',
                          prefixIcon: Icon(Icons.local_movies_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          hintText: 'Release year',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final year = int.tryParse(value);
                            if (year == null || year < 1900 || year > DateTime.now().year + 5) {
                              return 'Invalid year';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _posterUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Poster URL',
                        hintText: 'Image URL for movie poster',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath || (!uri.isScheme('http') && !uri.isScheme('https'))) {
                            return 'Please enter a valid URL';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildFormSection(
              title: 'Status',
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text('Mark as Watched'),
                    subtitle: Text(
                      _isWatched ? 'You have watched this item' : 'Add to your watchlist',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _isWatched,
                    onChanged: (value) {
                      setState(() {
                        _isWatched = value;
                        if (!value) _rating = null;
                      });
                    },
                  ),
                ),
                if (_isWatched) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Rating',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'How would you rate this ${_selectedType}?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            final isSelected = index < (_rating ?? 0);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  isSelected ? Icons.star : Icons.star_border,
                                  color: isSelected ? Colors.amber : Colors.grey,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_rating != null)
                          Text(
                            '${_rating}/5 stars',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteItem,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _saveItem,
                    icon: Icon(isEditing ? Icons.update : Icons.add),
                    label: Text(isEditing ? 'Update Item' : 'Add to Watchlist'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final item = WatchlistItem(
        title: _titleController.text,
        type: _selectedType,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        genre: _genreController.text.isEmpty ? null : _genreController.text,
        year: _yearController.text.isEmpty ? null : int.parse(_yearController.text),
        isWatched: _isWatched,
        dateAdded: widget.item?.dateAdded ?? DateTime.now(),
        rating: _isWatched ? _rating : null,
        posterUrl: _posterUrlController.text.isEmpty ? null : _posterUrlController.text,
        // Include IMDb data if available
        imdbRating: _selectedMovie?.imdbData?.rating,
        imdbVotes: _selectedMovie?.imdbData?.voteCount,
        imdbId: _selectedMovie?.imdbData?.imdbId,
      );

      if (widget.item != null) {
        // Update existing item
        widget.item!.title = item.title;
        widget.item!.type = item.type;
        widget.item!.description = item.description;
        widget.item!.genre = item.genre;
        widget.item!.year = item.year;
        widget.item!.isWatched = item.isWatched;
        widget.item!.rating = item.rating;
        widget.item!.posterUrl = item.posterUrl;
        await StorageService.updateItem(widget.item!);
      } else {
        // Add new item
        await StorageService.addItem(item);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }



  void _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Delete Item'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.item != null) {
      await StorageService.deleteItem(widget.item!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTitleAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'Search for a movie or TV series',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ) 
                : null,
          ),
          onChanged: _searchMovies,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
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
                          child: Image.network(
                            result.fullPosterUrl,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 60,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.image_not_supported, size: 20),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 60,
                          color: Colors.grey.shade800,
                          child: Icon(
                            result.mediaType == 'movie' ? Icons.movie : Icons.tv,
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
        if (_selectedMovie != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                if (_selectedMovie!.posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      _selectedMovie!.fullPosterUrl,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMovie!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedMovie!.year != null)
                        Text(
                          'Year: ${_selectedMovie!.year}',
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                      if (_selectedMovie!.genres.isNotEmpty)
                        Text(
                          'Genre: ${_selectedMovie!.genres.join(', ')}',
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                      if (_selectedMovie!.voteAverage != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_selectedMovie!.voteAverage!.toStringAsFixed(1)}/10',
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
      print('Error searching movies: $e');
    }
  }

  Future<void> _selectMovie(MovieSearchResult movie) async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final details = await MovieSearchService.getDetails(movie.id, movie.mediaType);
      
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
          _selectedType = details.mediaType;
          
          // Display IMDb data if available
          if (details.imdbData != null) {
            print('IMDb data found: ${details.imdbData!.rating} (${details.imdbData!.voteCount} votes)');
          }
        });
      }
    } catch (e) {
      print('Error getting movie details: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }
}