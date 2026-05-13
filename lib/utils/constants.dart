// App-wide constants
class AppConstants {
  // Firebase collections
  static const String recipesCollection = 'tbl_recipes';
  static const String usersCollection = 'tbl_users';

  // Recipe categories
  static const List<String> categories = [
    'All',
    'vegetarian',
    'non-vegetarian',
    'dessert',
  ];

  // Budget constraints
  static const double minBudget = 99.0;
  static const double maxBudget = 999.0;
  static const int budgetDivisions = 180;

  // Error messages
  static const String genericError = 'An error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
}

