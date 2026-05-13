import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:peso_pantry/models/recipe_model.dart';
import 'package:peso_pantry/models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // ===== RECIPE OPERATIONS =====
  static Future<List<Recipe>> getAllRecipes() async {
    try {
      final snapshot = await _firestore.collection('tbl_recipes').get();
      return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  static Future<Recipe> getRecipeById(String recipeId) async {
    try {
      final doc = await _firestore.collection('tbl_recipes').doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromJson(doc.data() as Map<String, dynamic>);
      }
      throw Exception('Recipe not found');
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching recipes by category: $e');
    }
  }

  static Future<List<Recipe>> getRecipesByBudget(double maxCost) async {
    try {
      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where('cost_estimate', isLessThanOrEqualTo: maxCost)
          .get();
      return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching recipes by budget: $e');
    }
  }

  // ===== USER OPERATIONS =====
  static Future<void> createUser(String userId, String email) async {
    try {
      await _firestore.collection('tbl_users').doc(userId).set({
        'user_id': userId,
        'email': email,
        'budget': 0.0,
        'saved_recipes': [],
        'meal_plans': [],
      });
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  static Future<AppUser> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('tbl_users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  static Future<void> updateUserBudget(String userId, double newBudget) async {
    try {
      await _firestore
          .collection('tbl_users')
          .doc(userId)
          .update({'budget': newBudget});
    } catch (e) {
      throw Exception('Error updating budget: $e');
    }
  }

  static Future<void> saveRecipe(String userId, String recipeId) async {
    try {
      await _firestore.collection('tbl_users').doc(userId).update({
        'saved_recipes': FieldValue.arrayUnion([recipeId])
      });
    } catch (e) {
      throw Exception('Error saving recipe: $e');
    }
  }

  static Future<void> unsaveRecipe(String userId, String recipeId) async {
    try {
      await _firestore.collection('tbl_users').doc(userId).update({
        'saved_recipes': FieldValue.arrayRemove([recipeId])
      });
    } catch (e) {
      throw Exception('Error unsaving recipe: $e');
    }
  }

  static Future<List<Recipe>> getUserSavedRecipes(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user.savedRecipes.isEmpty) return [];

      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where(FieldPath.documentId, whereIn: user.savedRecipes)
          .get();
      return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching saved recipes: $e');
    }
  }
}

