import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'dart:async';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/product_model.dart';
import '../../shared/service/database_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/input_widget.dart';

// Sort options for the search screen
enum SortOption { nameAsc, nameDesc, priceAsc, priceDesc, ratingDesc }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImageBase64 _imageConverter = ImageBase64();
  List<Product> _searchResults = [];
  List<Product> _allProducts = [];
  bool _isSearching = false;
  bool _hasActiveFilters = false;

  // Debounce timer for search
  Timer? _debounce;

  // Filter state
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _minRating = 0;
  List<String> _selectedTags = [];
  Set<String> _availableTags = {};
  
  // Sort state
  SortOption _currentSortOption = SortOption.nameAsc;
  
  // Search history
  final List<String> _searchHistory = [];
  final int _maxHistoryItems = 5;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    try {
      final databaseService = DatabaseService();
      _allProducts = await databaseService.getAllProducts();
      _extractAvailableTags();
    } catch (e) {
      if (mounted) {
        SnackbarWidget.show(
          context: context,
          message: 'Error loading products: ${e.toString()}',
        );
      }
    }
  }

  void _extractAvailableTags() {
    final tags = _allProducts.expand((product) => product.tags).toSet();
    setState(() {
      _availableTags = tags;
    });
  }

  void _searchProducts(String query) {
    // Cancel any previous debounce timer
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Create a new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);

      // Add to search history if it's a new query
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > _maxHistoryItems) {
            _searchHistory.removeLast();
          }
        });
      }

      // Apply both search and filters
      final results = _allProducts.where((product) {
        // Search criteria
        final nameMatch =
            product.name.toLowerCase().contains(query.toLowerCase());
        final descMatch =
            product.description.toLowerCase().contains(query.toLowerCase());
        final tagMatch = product.tags
            .any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        final searchMatch = nameMatch || descMatch || tagMatch;

        // Filter criteria
        final priceMatch =
            product.price >= _minPrice && product.price <= _maxPrice;
        final ratingMatch = product.rate >= _minRating;
        final tagsMatch = _selectedTags.isEmpty ||
            _selectedTags.any((tag) => product.tags.contains(tag));

        return searchMatch && priceMatch && ratingMatch && tagsMatch;
      }).toList();

      // Apply sorting
      _applySorting(results);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _applySorting(List<Product> results) {
    switch (_currentSortOption) {
      case SortOption.nameAsc:
        results.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        results.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.priceAsc:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        results.sort((a, b) => b.rate.compareTo(a.rate));
        break;
    }
  }

  Future<void> _refreshProducts() async {
    setState(() => _isSearching = true);
    await _loadAllProducts();
    _searchProducts(_searchController.text);
  }

  void _navigateToProductDetails(Product product) {
    // Navigate to product details screen
    Navigator.pushNamed(
      context,
      '/product-details',
      arguments: product,
    );
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 1000;
      _minRating = 0;
      _selectedTags = [];
      _hasActiveFilters = false;
    });
    _searchProducts(_searchController.text);
    Navigator.pop(context); // Close the drawer
  }

  void _applyFilters() {
    // Check if any filters are active
    final hasActiveFilters = 
        _minPrice > 0 || 
        _maxPrice < 1000 || 
        _minRating > 0 || 
        _selectedTags.isNotEmpty;
    
    setState(() {
      _hasActiveFilters = hasActiveFilters;
    });
    
    _searchProducts(_searchController.text);
    Navigator.pop(context); // Close the drawer
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      backgroundColor: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Price Range Filter
                  const Text('Price Range',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RangeSlider(
                    activeColor: AppTheme.accentColor,
                    inactiveColor: AppTheme.greyShadeColor,
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_minPrice.toStringAsFixed(2)}',
                      '\$${_maxPrice.toStringAsFixed(2)}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${_minPrice.toStringAsFixed(2)}'),
                        Text('\$${_maxPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rating Filter
                  const Text('Minimum Rating',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Slider(
                    activeColor: AppTheme.accentColor,
                    inactiveColor: AppTheme.greyShadeColor,
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('0'),
                        Row(
                          children: [
                            Text(_minRating.toStringAsFixed(1)),
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                          ],
                        ),
                        const Text('5'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags Filter
                  const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_availableTags.isEmpty)
                    const Text('No tags available')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: AppTheme.accentColor.withOpacity(0.3),
                          checkmarkColor: AppTheme.accentColor,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                    ),
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    style: AppTheme.buttonStyle,
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: "Search"),
      drawer: _buildFilterDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              InputFieldWidget(
                label: 'Search',
                controller: _searchController,
                type: FieldType.normal,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : const Icon(Icons.search),
                onChanged: (value) async => _searchProducts(value.toString()),
              ),
              const SizedBox(height: 8),
              
              // Filter and sort options row
              if (_searchResults.isNotEmpty || _hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Filter button with indicator
                          GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Chip(
                              avatar: Icon(
                                Icons.filter_list,
                                size: 18,
                                color: _hasActiveFilters ? AppTheme.accentColor : Colors.grey,
                              ),
                              label: Text(
                                'Filter',
                                style: TextStyle(
                                  color: _hasActiveFilters ? AppTheme.accentColor : null,
                                  fontWeight: _hasActiveFilters ? FontWeight.bold : null,
                                ),
                              ),
                              backgroundColor: _hasActiveFilters 
                                  ? AppTheme.accentColor.withOpacity(0.1) 
                                  : null,
                            ),
                          ),
                          if (_searchResults.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text('${_searchResults.length} results'),
                            ),
                        ],
                      ),
                      // Sort dropdown
                      if (_searchResults.isNotEmpty)
                        DropdownButton<SortOption>(
                          value: _currentSortOption,
                          icon: const Icon(Icons.sort),
                          onChanged: (SortOption? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _currentSortOption = newValue;
                                _applySorting(_searchResults);
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<SortOption>(
                              value: SortOption.nameAsc,
                              child: const Text('Name (A-Z)'),
                            ),
                            DropdownMenuItem<SortOption>(
                              value: SortOption.nameDesc,
                              child: const Text('Name (Z-A)'),
                            ),
                            DropdownMenuItem<SortOption>(
                              value: SortOption.priceAsc,
                              child: const Text('Price (Low-High)'),
                            ),
                            DropdownMenuItem<SortOption>(
                              value: SortOption.priceDesc,
                              child: const Text('Price (High-Low)'),
                            ),
                            DropdownMenuItem<SortOption>(
                              value: SortOption.ratingDesc,
                              child: const Text('Rating (Best)'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              
              // Search history
              if (_searchHistory.isNotEmpty && _searchController.text.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Searches', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchHistory.clear();
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _searchHistory.map((query) => ActionChip(
                        label: Text(query),
                        onPressed: () {
                          _searchController.text = query;
                          _searchProducts(query);
                        },
                        avatar: const Icon(Icons.history, size: 16),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                
              if (_isSearching)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_searchResults.isEmpty &&
                  _searchController.text.isNotEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No products found'),
                      ],
                    ),
                  ),
                )
              else if (_searchResults.isEmpty && _searchController.text.isEmpty && _searchHistory.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Search for products'),
                      ],
                    ),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return GestureDetector(
                        onTap: () => _navigateToProductDetails(product),
                        child: _ProductCard(
                          product: product,
                          imageConverter: _imageConverter,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final ImageBase64 imageConverter;

  const _ProductCard({
    required this.product,
    required this.imageConverter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.imagesBase64?.isNotEmpty ?? false
                    ? imageConverter.toImage(
                        product.imagesBase64!.first,
                        fit: BoxFit.cover,
                      )
                    : imageConverter.toImage(
                        null,
                        name: product.name,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: product.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey[200],
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product.rate > 0)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              product.rate.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
