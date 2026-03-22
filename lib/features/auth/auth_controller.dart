// lib/features/auth/auth_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_pages.dart';
import '../../core/services/firebase/firebase_auth_service.dart';
import '../../data/models/user_model.dart' as app_user;

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  static AuthController instance = Get.find();

  // Profile details
  RxString name = ''.obs;
  RxString goalType = ''.obs;
  RxString email = ''.obs;
  RxString role = 'customer'.obs;
  RxDouble height = 0.0.obs;
  RxDouble weight = 0.0.obs;
  RxInt age = 0.obs;

  // Observable variables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<app_user.UserModel?> user = Rx<app_user.UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;

  // Timer for email verification check
  Timer? _emailVerificationTimer;
  bool _autoNavigateEnabled = true;

  @override
  void onInit() {
    super.onInit();
    initializeUser();
  }

  @override
  void onClose() {
    _emailVerificationTimer?.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(firebaseUser, _setUserDataFromFirestore); // Highlighted
  }

  Future<void> _setUserDataFromFirestore(User? user) async {
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      name.value = data['name'] ?? '';
      goalType.value = data['goalType'] ?? '';
      email.value = data['email'] ?? '';
      role.value = data['role'] ?? 'customer';
      height.value = double.tryParse(data['height']?.toString() ?? '0') ?? 0.0;
      weight.value = double.tryParse(data['weight']?.toString() ?? '0') ?? 0.0;
      age.value = int.tryParse(data['age']?.toString() ?? '0') ?? 0;
    }
  }

  // Initialize user state
  Future<void> initializeUser() async {
    try {
      // Set up firebase user listener
      firebaseUser.bindStream(_authService.authStateChanges);

      // Listen to auth changes and handle navigation only when enabled
      ever(firebaseUser, (User? user) {
        if (_autoNavigateEnabled) {
          _handleAuthStateChanges(user);
        }
      });

      // Check if first time user
      await _checkFirstTimeUser();

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Error initializing auth: $e';
      print('AuthController init error: $e');
      isInitialized.value = true; // Consider it initialized even with error
    }
  }

  // Check if user is opening the app for the first time
  Future<void> _checkFirstTimeUser() async {
    try {
      isFirstTime.value = await _authService.isFirstTimeUser();
    } catch (e) {
      errorMessage.value = 'Error checking first time status: $e';
      print('First time check error: $e');
      isFirstTime.value = true; // Default to true if error
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      await _authService.completeOnboarding();
      isFirstTime.value = false;
    } catch (e) {
      errorMessage.value = 'Error completing onboarding: $e';
      print('Complete onboarding error: $e');
    }
  }

  // Disable auto navigation (useful during registration/login flows)
  void disableAutoNavigation() {
    _autoNavigateEnabled = false;
  }

  // Enable auto navigation
  void enableAutoNavigation() {
    _autoNavigateEnabled = true;
    // Trigger navigation based on current state
    if (firebaseUser.value != null) {
      _handleAuthStateChanges(firebaseUser.value);
    }
  }

  // Handle auth state changes
  void _handleAuthStateChanges(User? user) async {
    try {
      if (user == null) {
        // User is not logged in
        if (isFirstTime.value) {
          // First time user, go to onboarding
          Get.offAllNamed(Routes.onboarding);
        } else {
          // Returning user who's logged out, go to welcome
          Get.offAllNamed(Routes.welcome);
        }
      } else {
        // User is logged in
        if (!user.emailVerified) {
          // Email not verified, go to verification screen
          Get.offAllNamed(Routes.emailVerification);
        } else {
          // Email verified, go to main screen or specific dashboard
          try {
            // Fetch user data
            await fetchUserData();
            
            // Route based on role or hardcoded admin email
            if (user.email == 'admin@gmail.com' || this.user.value?.role == 'admin') {
              Get.offAllNamed(Routes.adminDashboard);
            } else if (this.user.value?.role == 'coach') {
              Get.offAllNamed(Routes.coachDashboard); // Assumes we add this route
            } else {
              Get.offAllNamed(Routes.main);
            }
          } catch (e) {
            errorMessage.value = 'Error loading user data: $e';
            print('Error loading user data: $e');
            
            // Still try to navigate based on fallback if user data fetch fails
            if (user.email == 'admin@gmail.com') {
              Get.offAllNamed(Routes.adminDashboard);
            } else {
              Get.offAllNamed(Routes.main);
            }
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Navigation error: $e';
      print('Auth state change error: $e');
    }
  }

  // Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Disable auto navigation during registration
      disableAutoNavigation();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        userData: userData,
      );

      // Send email verification
      await _authService.sendEmailVerification();

      isLoading.value = false;

      // Re-enable auto navigation and trigger navigation
      enableAutoNavigation();

      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _authService.handleAuthError(e);
      print(
        'Firebase auth error during registration: ${e.code} - ${e.message}',
      );
      // Re-enable auto navigation even on error
      enableAutoNavigation();
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('Error during registration: $e');
      // Re-enable auto navigation even on error
      enableAutoNavigation();
      return false;
    }
  }

  // Login with email and password
  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Disable auto navigation during login
      disableAutoNavigation();

      await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("Login timed out. Check emulator connection.");
      });

      isLoading.value = false;

      // Re-enable auto navigation and trigger navigation
      enableAutoNavigation();

      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _authService.handleAuthError(e);
      print('Firebase auth error during login: ${e.code} - ${e.message}');
      // Re-enable auto navigation even on error
      enableAutoNavigation();
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('Error during login: $e');
      // Re-enable auto navigation even on error
      enableAutoNavigation();
      return false;
    }
  }

  // Send password reset email
  Future<bool> forgotPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.sendPasswordResetEmail(email);
      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _authService.handleAuthError(e);
      print(
        'Firebase auth error during password reset: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('Error during password reset: $e');
      return false;
    }
  }

  // Start email verification check
  void startEmailVerificationCheck() {
    try {
      // Cancel any existing timer
      _emailVerificationTimer?.cancel();

      // Create a new timer to check email verification status every 3 seconds
      _emailVerificationTimer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) => _checkEmailVerification(),
      );
    } catch (e) {
      errorMessage.value = 'Error starting verification check: $e';
      print('Email verification timer error: $e');
    }
  }

  // Stop email verification check
  void stopEmailVerificationCheck() {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = null;
  }

  // Check if email is verified
  Future<void> _checkEmailVerification() async {
    try {
      if (firebaseUser.value != null) {
        await _authService.reloadUser();

        // Get fresh user
        final user = _authService.currentUser;

        if (user != null && user.emailVerified) {
          stopEmailVerificationCheck();
          Get.offAllNamed(Routes.main);
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
      // Don't stop the timer on error
    }
  }

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.sendEmailVerification();
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('Error resending verification email: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      user.value = null;
      role.value = 'customer';
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error during logout: $e');
      // Still try to navigate to login screen even if logout fails
      user.value = null;
      role.value = 'customer';
      Get.offAllNamed(Routes.welcome);
    }
  }

  // Fetch user data
  Future<void> fetchUserData() async {
    try {
      user.value = await _authService.getUserData().timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Fetching user data timed out.");
      });
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching user data: $e');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _authService.updateUserProfile(userData);

      if (success) {
        // Refresh user data
        await fetchUserData();
      }

      isLoading.value = false;
      return success;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    try {
      return _authService.isLoggedIn();
    } catch (e) {
      errorMessage.value = 'Error checking login status: $e';
      print('Login check error: $e');
      return false; // Default to false if error
    }
  }

  // Show success message
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  // Show error message
  void showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  // Get available coaches for registration
  Future<List<app_user.UserModel>> getAvailableCoaches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'coach')
          .get();
      return snapshot.docs
          .map((doc) => app_user.UserModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting coaches: $e');
      return [];
    }
  }
}
