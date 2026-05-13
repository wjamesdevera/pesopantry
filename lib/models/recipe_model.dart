// Recipe data model matching tbl_recipes
class Recipe {
  final String recipeId;  // Document ID used for Firestore lookups
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String category;
  final double costEstimate;
  final int cookingTime;
  final String imageUrl;
  final String? documentId;  // Store actual Firestore document ID

  Recipe({
    required this.recipeId,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.category,
    required this.costEstimate,
    required this.cookingTime,
    required this.imageUrl,
    this.documentId,
  });

  // Convert Firestore document to Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Helper function to safely convert cost_estimate
    double parseCost(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to safely convert cooking_time
    int parseCookingTime(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Use document ID as primary identifier, fallback to recipe_id field
    final finalRecipeId = docId ?? json['recipe_id']?.toString() ?? '';

    return Recipe(
      recipeId: finalRecipeId,
      title: json['title']?.toString() ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: json['instructions']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      costEstimate: parseCost(json['cost_estimate']),
      cookingTime: parseCookingTime(json['cooking_time']),
      imageUrl: json['image_url']?.toString() ?? '',
      documentId: docId,
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

