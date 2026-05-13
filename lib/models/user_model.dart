// User data model matching tbl_users
class AppUser {
  final String userId;
  final String email;
  final double budget;
  final List<String> savedRecipes;
  final List<String> mealPlans;

  AppUser({
    required this.userId,
    required this.email,
    required this.budget,
    this.savedRecipes = const [],
    this.mealPlans = const [],
  });

  // Convert Firestore document to AppUser object
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      savedRecipes: List<String>.from(json['saved_recipes'] ?? []),
      mealPlans: List<String>.from(json['meal_plans'] ?? []),
    );
  }

  // Convert AppUser to map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'budget': budget,
      'saved_recipes': savedRecipes,
      'meal_plans': mealPlans,
    };
  }
}

