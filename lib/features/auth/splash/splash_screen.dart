import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  AuthController? _authController;

  @override
  void initState() {
    super.initState();

    // Get existing AuthController if it exists, otherwise create new one
    try {
      _authController = Get.find<AuthController>();
      print('Found existing AuthController');
    } catch (e) {
      print('Creating new AuthController: $e');
      _authController = Get.put(AuthController());
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Initialize and navigate
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Ensure AuthController is fully initialized
      if (_authController != null && !_authController!.isInitialized.value) {
        await _authController!.initializeUser();
      }

      // Disable auto navigation to prevent premature navigation
      _authController?.disableAutoNavigation();

      // Wait for animation to complete
      await _animationController.forward();

      // Wait for minimum splash time
      await Future.delayed(const Duration(milliseconds: 300));

      // Now navigate based on state
      if (_authController != null) {
        if (_authController!.isUserLoggedIn()) {
          if (_authController!.firebaseUser.value?.emailVerified ?? false) {
            Get.offAllNamed(Routes.main);
          } else {
            Get.offAllNamed(Routes.emailVerification);
          }
        } else if (_authController!.isFirstTime.value) {
          Get.offAllNamed(Routes.onboarding);
        } else {
          Get.offAllNamed(Routes.welcome);
        }
      } else {
        // Fallback if no controller
        Get.offAllNamed(Routes.welcome);
      }

      // Re-enable auto navigation after navigation is complete
      _authController?.enableAutoNavigation();
    } catch (e) {
      print('Navigation error: $e');
      Get.offAllNamed(Routes.welcome);
      _authController?.enableAutoNavigation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.blueGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App Name
                        const Text(
                          "FitTrack",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tagline
                        const Text(
                          "Your fitness journey starts here",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Loading indicator
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
