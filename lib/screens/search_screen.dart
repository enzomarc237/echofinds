import 'package:flutter/material.dart';
import 'package:echofinds/models/alternative.dart';
import 'package:echofinds/models/search_history.dart';
import 'package:echofinds/services/storage_service.dart';
import 'package:echofinds/services/alternative_finder_service.dart';
import 'package:echofinds/utils/constants.dart';
import 'package:echofinds/widgets/category_chip.dart';
import 'package:echofinds/widgets/search_bar_widget.dart';
import 'package:echofinds/widgets/alternative_card.dart';
import 'package:echofinds/widgets/filter_bottom_sheet.dart';
import 'package:echofinds/screens/alternative_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = 'All';
  List<Alternative> _searchResults = [];
  List<Alternative> _filteredResults = [];
  List<SearchHistory> _recentSearches = [];
  
  bool _isLoading = false;
  bool _showResults = false;
  String _errorMessage = '';
  
  // Filter options
  List<String> _selectedPricingModels = [];
  List<String> _selectedPlatforms = [];
  String _selectedSortOption = AppConstants.sortOptions.first;
  
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  late Animation<Offset> _resultsAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchBarAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _resultsAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRecentSearches() async {
    final history = await StorageService.getSearchHistory();
    if (mounted) {
      setState(() => _recentSearches = history.take(5).toList());
    }
  }
  
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final results = await AlternativeFinderService.findAlternatives(query, _selectedCategory);
      
      // Save to search history
      final searchHistory = SearchHistory(
        query: query,
        category: _selectedCategory,
        timestamp: DateTime.now(),
        resultsCount: results.length,
      );
      await StorageService.addSearchHistory(searchHistory);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _filteredResults = results;
          _showResults = true;
          _isLoading = false;
        });
        
        _animationController.forward();
        await _loadRecentSearches();
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredResults = _searchResults.where((alt) {
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
          _filteredResults.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Name (Z-A)':
          _filteredResults.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Rating':
          _filteredResults.sort((a, b) => 
              (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
        case 'Popularity':
          _filteredResults.sort((a, b) => 
              (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0));
          break;
        default: // Relevance - keep original order
          break;
      }
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _filteredResults.clear();
      _showResults = false;
      _errorMessage = '';
    });
    _animationController.reverse();
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
  
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];
              return CategoryChip(
                category: category,
                isSelected: _selectedCategory == category,
                onTap: () => setState(() => _selectedCategory = category),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Recent Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentSearches.map((history) =>
          ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(history.query),
            subtitle: Text('${history.category} • ${history.resultsCount} results'),
            trailing: Text(
              _formatDate(history.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () {
              _searchController.text = history.query;
              _selectedCategory = history.category;
              _performSearch();
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _showResults
                        ? [cs.surface, cs.surface]
                        : [
                            cs.primary.withValues(alpha: 0.05),
                            cs.tertiary.withValues(alpha: 0.05),
                          ],
                  ),
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _searchBarAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _searchBarAnimation.value),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_showResults) ...[
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [cs.primary, cs.tertiary],
                              ).createShader(bounds),
                              child: Text(
                                'Find Alternatives',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Discover better alternatives to any software, app, or service',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildCategorySelection(),
                            const SizedBox(height: 24),
                          ],
                          SearchBarWidget(
                            controller: _searchController,
                            hintText: 'Enter app, software, or service name...',
                            onSearch: _performSearch,
                            onClear: _clearSearch,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (!_showResults) _buildRecentSearches(),
                  
                  if (_showResults) ...[
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _resultsAnimation,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_filteredResults.length} alternatives found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _showFilterBottomSheet,
                                icon: Icon(
                                  Icons.tune,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: 'Filter results',
                              ),
                              IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close, color: Colors.grey),
                                tooltip: 'Clear search',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredResults.length,
                            itemBuilder: (context, index) {
                              final alternative = _filteredResults[index];
                              return AlternativeCard(
                                alternative: alternative,
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 300),
                                    pageBuilder: (_, animation, __) => FadeTransition(
                                      opacity: animation,
                                      child: AlternativeDetailScreen(alternative: alternative),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}