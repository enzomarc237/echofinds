import 'package:flutter/material.dart';
import 'package:echofinds/models/alternative.dart';
import 'package:echofinds/services/storage_service.dart';
import 'package:echofinds/widgets/alternative_card.dart';
import 'package:echofinds/screens/alternative_detail_screen.dart';
import 'package:echofinds/utils/constants.dart';
import 'package:echofinds/widgets/filter_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Alternative> _favorites = [];
  List<Alternative> _filteredFavorites = [];
  bool _isLoading = true;
  
  // Filter options
  List<String> _selectedPricingModels = [];
  List<String> _selectedPlatforms = [];
  String _selectedSortOption = AppConstants.sortOptions.first;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    final favorites = await StorageService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _filteredFavorites = favorites;
        _isLoading = false;
      });
      _applyFilters();
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredFavorites = _favorites.where((alt) {
        // Filter by pricing model
        if (_selectedPricingModels.isNotEmpty &&
            !_selectedPricingModels.contains(alt.pricingModel)) {
          return false;
        }
        
        // Filter by platforms
        if (_selectedPlatforms.isNotEmpty &&
            !alt.platforms.any((platform) => _selectedPlatforms.contains(platform))) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Apply sorting
      switch (_selectedSortOption) {
        case 'Name (A-Z)':
          _filteredFavorites.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Name (Z-A)':
          _filteredFavorites.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Rating':
          _filteredFavorites.sort((a, b) => 
              (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
        case 'Popularity':
          _filteredFavorites.sort((a, b) => 
              (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0));
          break;
        default: // Relevance - keep original order
          break;
      }
    });
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedPricingModels: _selectedPricingModels,
        selectedPlatforms: _selectedPlatforms,
        selectedSortOption: _selectedSortOption,
        onApplyFilters: (pricingModels, platforms, sortOption) {
          setState(() {
            _selectedPricingModels = pricingModels;
            _selectedPlatforms = platforms;
            _selectedSortOption = sortOption;
          });
          _applyFilters();
        },
      ),
    );
  }
  
  Future<void> _clearAllFavorites() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (shouldClear == true) {
      // Clear all favorites by removing each one
      for (final favorite in _favorites) {
        await StorageService.removeFavorite(favorite);
      }
      await _loadFavorites();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All favorites cleared')),
        );
      }
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring alternatives and add them to your favorites',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (_favorites.isNotEmpty) ...[
            IconButton(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.tune),
              tooltip: 'Filter favorites',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllFavorites();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      if (_filteredFavorites.length != _favorites.length)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          child: Text(
                            'Showing ${_filteredFavorites.length} of ${_favorites.length} favorites',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: _filteredFavorites.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.filter_list_off,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No favorites match your filters',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedPricingModels.clear();
                                          _selectedPlatforms.clear();
                                          _selectedSortOption = AppConstants.sortOptions.first;
                                        });
                                        _applyFilters();
                                      },
                                      child: const Text('Clear filters'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _filteredFavorites.length,
                                itemBuilder: (context, index) {
                                  final alternative = _filteredFavorites[index];
                                  return AlternativeCard(
                                    alternative: alternative,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 300),
                                          pageBuilder: (_, animation, __) => FadeTransition(
                                            opacity: animation,
                                            child: AlternativeDetailScreen(
                                              alternative: alternative,
                                            ),
                                          ),
                                        ),
                                      );
                                      // Reload favorites in case the user removed it from details screen
                                      _loadFavorites();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}