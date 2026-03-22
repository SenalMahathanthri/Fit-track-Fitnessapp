// lib/core/services/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to track auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is first time (no onboarding completed flag)
  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    // If onboarding_completed doesn't exist or is false, it's first time
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    return !onboardingCompleted; // If it's not completed, it's first time
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return currentUser != null;
  }

  // Check if email is verified
  bool isEmailVerified() {
    return currentUser?.emailVerified ?? false;
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // 1. Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Add user ID to userData
      userData['uid'] = userCredential.user!.uid;

      // 3. Create user profile in Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    if (currentUser != null && !currentUser!.emailVerified) {
      await currentUser!.sendEmailVerification();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reload user (to check for email verification)
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // Get user data from Firestore
  Future<app_user.UserModel?> getUserData() async {
    if (currentUser == null) return null;

    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (userDoc.exists) {
        return app_user.UserModel.fromMap(currentUser!.uid, userDoc.data()!);
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(userData);

      // Update auth profile fields if available
      if (userData.containsKey('name')) {
        await currentUser!.updateDisplayName(userData['name']);
      }

      if (userData.containsKey('email')) {
        await currentUser!.updateEmail(userData['email']);
      }

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    if (currentUser == null) return false;

    try {
      await currentUser!.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Handle auth error messages
  String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'invalid-credential':
        return 'Invalid login credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
