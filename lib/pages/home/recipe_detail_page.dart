import 'package:flutter/material.dart';
import 'package:peso_pantry/config/app_theme.dart';
import 'package:peso_pantry/models/recipe_model.dart';
import 'package:peso_pantry/services/auth_service.dart';
import 'package:peso_pantry/services/firebase_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<Recipe> _recipeFuture;
  bool _isSaved = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _recipeFuture = FirebaseService.getRecipeById(widget.recipeId);
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId != null) {
        final user = await FirebaseService.getUserById(userId);
        setState(() {
          _isSaved = user.savedRecipes.contains(widget.recipeId);
        });
      }
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _toggleSave(Recipe recipe) async {
    if (_isTogglingFavorite) return;

    final userId = AuthService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save recipes')),
      );
      return;
    }

    setState(() => _isTogglingFavorite = true);
    try {
      if (_isSaved) {
        await FirebaseService.unsaveRecipe(userId, recipe.recipeId);
        setState(() => _isSaved = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe removed from saved')),
        );
      } else {
        await FirebaseService.saveRecipe(userId, recipe.recipeId);
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Recipe not found'));
          }

          final recipe = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.grey[300],
                    child: recipe.imageUrl.isEmpty
                        ? const Icon(Icons.image_not_supported, size: 80)
                        : Image.network(recipe.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _isSaved ? AppTheme.secondary : Colors.white,
                    ),
                    onPressed: () => _toggleSave(recipe),
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard(
                            icon: Icons.schedule,
                            label: 'Cooking Time',
                            value: '${recipe.cookingTime} min',
                            context: context,
                          ),
                          _buildInfoCard(
                            icon: Icons.attach_money,
                            label: 'Cost Estimate',
                            value: '\$${recipe.costEstimate.toStringAsFixed(2)}',
                            context: context,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Ingredients section
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(entry.value),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      // Instructions section
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe.instructions,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleSave(recipe),
                          icon: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          label: Text(
                            _isSaved ? 'Saved' : 'Save Recipe',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


