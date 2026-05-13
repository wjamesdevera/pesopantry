// Recipe data model matching tbl_recipes
class Recipe {
  final String recipeId;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String category;
  final double costEstimate;
  final int cookingTime;
  final String imageUrl;

  Recipe({
    required this.recipeId,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.category,
    required this.costEstimate,
    required this.cookingTime,
    required this.imageUrl,
  });

  // Convert Firestore document to Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] ?? '',
      title: json['title'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: json['instructions'] ?? '',
      category: json['category'] ?? '',
      costEstimate: (json['cost_estimate'] ?? 0).toDouble(),
      cookingTime: json['cooking_time'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  // Convert Recipe to map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'category': category,
      'cost_estimate': costEstimate,
      'cooking_time': cookingTime,
      'image_url': imageUrl,
    };
  }
}

