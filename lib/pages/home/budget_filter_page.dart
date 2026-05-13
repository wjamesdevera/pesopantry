import 'package:flutter/material.dart';
import 'package:peso_pantry/config/app_theme.dart';
import 'package:peso_pantry/models/recipe_model.dart';
import 'package:peso_pantry/services/firebase_service.dart';
import 'package:peso_pantry/widgets/recipe_card.dart';

class BudgetFilterPage extends StatefulWidget {
  const BudgetFilterPage({Key? key}) : super(key: key);

  @override
  State<BudgetFilterPage> createState() => _BudgetFilterPageState();
}

class _BudgetFilterPageState extends State<BudgetFilterPage> {
  double _selectedBudget = 99.0;
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filterByBudget();
  }

  Future<void> _filterByBudget() async {
    setState(() => _isLoading = true);
    try {
      print('Filtering recipes by budget: ₱${_selectedBudget.toStringAsFixed(2)}...');
      final recipes = await FirebaseService.getRecipesByBudget(_selectedBudget);
      print('Found ${recipes.length} recipes within budget');
      setState(() {
        _filteredRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Budget filter error: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onBudgetChanged(double value) {
    setState(() => _selectedBudget = value);
    _filterByBudget();
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.of(context).pushNamed(
      '/recipe-detail',
      arguments: recipe.recipeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Filter',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          // Budget slider
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondary,
                  AppTheme.secondary.withOpacity(0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Your Budget',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Budget display card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accent.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maximum Spend',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₱${_selectedBudget.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.attach_money,
                          size: 48,
                          color: AppTheme.secondary.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Slider
                Slider(
                  value: _selectedBudget,
                  min: 99,
                  max: 999,
                  divisions: 180,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: _onBudgetChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₱99', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                    Text('₱999', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          // Results section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredRecipes.length} recipes found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          // Recipes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
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
                              'No recipes within budget',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try increasing your budget',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
        ],
      ),
    );
  }
}


