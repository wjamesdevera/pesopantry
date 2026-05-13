import 'package:flutter/material.dart';
import 'package:peso_pantry/config/app_theme.dart';
import 'package:peso_pantry/models/recipe_model.dart';
import 'package:peso_pantry/services/firebase_service.dart';
import 'package:peso_pantry/widgets/recipe_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  // Recipe data and filtering state
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = 'All';
  List<String> _categories = ['All']; // Will be populated dynamically
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Extract unique categories from recipes
  void _extractCategories(List<Recipe> recipes) {
    final categories = <String>{'All'};
    for (final recipe in recipes) {
      if (recipe.category.isNotEmpty) {
        categories.add(recipe.category);
      }
    }
    print('Found categories: $categories');
    setState(() {
      _categories.clear();
      _categories.addAll(categories);
    });
  }

  // Fetch all recipes from Firestore
  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final recipes = await FirebaseService.getAllRecipes();

      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        _isLoading = false;
      });

      // Extract categories from loaded recipes
      _extractCategories(recipes);

      print('Successfully loaded ${recipes.length} recipes');
    } catch (e) {
      print('Error loading recipes: $e');
      print('Stack trace: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load recipes: $e';
      });
      _showErrorSnackBar(_errorMessage!);
    }
  }

  // Apply search and category filters
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        // Search by title
        final titleMatch = recipe.title.toLowerCase().contains(query);

        // Filter by category (case-insensitive)
        final categoryMatch = _selectedCategory == 'All' ||
            recipe.category.toLowerCase() == _selectedCategory.toLowerCase();

        return titleMatch && categoryMatch;
      }).toList();
    });

    print('Filtered to ${_filteredRecipes.length} recipes (Category: $_selectedCategory, Search: "$query")');
  }

  // Handle category selection
  void _onCategoryChanged(String category) {
    print('Category changed to: $category');
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  // Navigate to recipe detail page
  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.of(context).pushNamed(
      '/recipe-detail',
      arguments: recipe.recipeId,
    );
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  // Build search section
  Widget _buildSearchSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Perfect Recipe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build category filter chips
  Widget _buildCategoryFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _onCategoryChanged(category),
                backgroundColor: Colors.white,
                selectedColor: AppTheme.secondary.withOpacity(0.2),
                side: BorderSide(
                  color: isSelected ? AppTheme.secondary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Display results count
  Widget _buildResultsCount(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${_filteredRecipes.length} recipes found',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Build recipes grid
  Widget _buildRecipesGrid() {
    return Expanded(
      child: _filteredRecipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => _navigateToRecipeDetail(recipe),
                );
              },
            ),
    );
  }

  // Build error state widget
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRecipes,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PesoPantry',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        elevation: 4,
        shadowColor: AppTheme.primary.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
              children: [
                _buildSearchSection(context),
                _buildCategoryFilter(context),
                _buildResultsCount(context),
                _buildRecipesGrid(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/budget-filter'),
        icon: const Icon(Icons.filter_alt),
        label: const Text('Budget'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }
}


