import 'package:firebase_auth/firebase_auth.dart';
import 'package:peso_pantry/services/firebase_service.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  static User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Register with email and password
  static Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user record in tbl_users
      if (userCredential.user != null) {
        await FirebaseService.createUser(
          userCredential.user!.uid,
          email,
        );
      }

      return userCredential;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Change password
  static Future<void> changePassword({required String newPassword}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Reset email failed: ${e.toString()}');
    }
  }
}

