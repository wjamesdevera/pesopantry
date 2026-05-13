import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:peso_pantry/models/recipe_model.dart';
import 'package:peso_pantry/models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      print('🔥 Initializing Firebase...');
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully');

      // Test Firestore connection
      print('🧪 Testing Firestore connection...');
      final testDoc = await FirebaseFirestore.instance
          .collection('tbl_recipes')
          .limit(1)
          .get();
      print('✅ Firestore connection successful - Found collections');

    } catch (e) {
      print('❌ Firebase initialization or Firestore connection error: $e');
      print('   Make sure:');
      print('   1. Firestore security rules allow read: if true;');
      print('   2. Cloud Firestore API is enabled in Google Cloud Console');
      print('   3. You are connected to the internet');
      rethrow;
    }
  }

  // ===== RECIPE OPERATIONS =====
  // Fetch all recipes from tbl_recipes collection
  static Future<List<Recipe>> getAllRecipes() async {
    try {
      print('📡 Fetching recipes from tbl_recipes...');
      final snapshot = await _firestore.collection('tbl_recipes').get();
      print('✅ Fetched ${snapshot.docs.length} recipe documents');

      final recipes = snapshot.docs.map((doc) {
        print('   - Recipe: ${doc.id}');
        final data = doc.data();
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();

      return recipes;
    } catch (e) {
      print('❌ Error fetching recipes: $e');
      print('   Error type: ${e.runtimeType}');
      throw Exception('Error fetching recipes: $e');
    }
  }

  // Get single recipe by ID
  static Future<Recipe> getRecipeById(String recipeId) async {
    try {
      print('📡 Fetching recipe: "$recipeId"...');
      print('   Recipe ID type: ${recipeId.runtimeType}');
      print('   Recipe ID length: ${recipeId.length}');

      if (recipeId.isEmpty) {
        throw Exception('Recipe ID is empty');
      }

      final doc = await _firestore.collection('tbl_recipes').doc(recipeId).get();
      if (doc.exists) {
        print('✅ Found recipe: $recipeId');
        final data = doc.data() as Map<String, dynamic>;
        return Recipe.fromJson(data, docId: doc.id);
      }

      // If not found by ID, try searching by recipe_id field
      print('⚠️  Document "$recipeId" not found, searching by recipe_id field...');
      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where('recipe_id', isEqualTo: recipeId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('✅ Found recipe by recipe_id field');
        final data = snapshot.docs.first.data();
        return Recipe.fromJson(data, docId: snapshot.docs.first.id);
      }

      throw Exception('Recipe not found: $recipeId');
    } catch (e) {
      print('❌ Error fetching recipe: $e');
      throw Exception('Error fetching recipe: $e');
    }
  }

  // Get recipes filtered by category (vegetarian, non-vegetarian, dessert)
  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching recipes by category: $e');
    }
  }

  // Get recipes within budget threshold
  static Future<List<Recipe>> getRecipesByBudget(double maxCost) async {
    try {
      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where('cost_estimate', isLessThanOrEqualTo: maxCost)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();
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

  // Get user's saved recipes
  static Future<List<Recipe>> getUserSavedRecipes(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user.savedRecipes.isEmpty) return [];

      final snapshot = await _firestore
          .collection('tbl_recipes')
          .where(FieldPath.documentId, whereIn: user.savedRecipes)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching saved recipes: $e');
    }
  }
}

