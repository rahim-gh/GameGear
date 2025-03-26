import 'package:flutter/material.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/product_model.dart';
import '../../shared/service/database_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/input_widget.dart';

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

  // Filter state
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _minRating = 0;
  List<String> _selectedTags = [];
  Set<String> _availableTags = {};

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    try {
      final databaseService = DatabaseService();
      _allProducts = await databaseService.getAllProducts();
      _extractAvailableTags();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: ${e.toString()}')),
      );
    }
  }

  void _extractAvailableTags() {
    final tags = _allProducts.expand((product) => product.tags).toSet();
    setState(() {
      _availableTags = tags;
    });
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

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

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 1000;
      _minRating = 0;
      _selectedTags = [];
    });
    _searchProducts(_searchController.text);
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      backgroundColor: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Price Range Filter
            const Text('Price Range',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
              onChangeEnd: (_) => _searchProducts(_searchController.text),
            ),

            // Rating Filter
            const Text('Minimum Rating',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
              onChangeEnd: (_) => _searchProducts(_searchController.text),
            ),

            // Tags Filter
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_availableTags.isEmpty)
              const Text('No tags available')
            else
              Wrap(
                spacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                      _searchProducts(_searchController.text);
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetFilters,
              style: AppTheme.buttonStyle,
              child: const Text('Reset Filters'),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InputFieldWidget(
              label: 'Search',
              controller: _searchController,
              type: 'normal',
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              suffixIcon: const Icon(Icons.search),
              onChanged: (value) async => _searchProducts(value),
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty &&
                _searchController.text.isNotEmpty)
              const Center(child: Text('No products found'))
            else if (_searchResults.isEmpty)
              const Center(child: Text('Search for products'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return _ProductCard(
                      product: product,
                      imageConverter: _imageConverter,
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
