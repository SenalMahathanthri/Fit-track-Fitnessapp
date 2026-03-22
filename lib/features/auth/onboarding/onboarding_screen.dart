// lib/features/auth/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthController _authController = Get.find<AuthController>();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Track Your Workouts",
      description:
          "Monitor your daily exercises and track your progress over time",
      imagePath: "assets/images/Onboarding1.png",
      color: AppColors.primaryBlue,
    ),
    OnboardingPage(
      title: "Meal Planning Made Easy",
      description:
          "Plan your nutrition with customized meal plans to meet your fitness goals",
      imagePath: "assets/images/Onboarding2.png",
      color: AppColors.primaryBlue,
    ),
    OnboardingPage(
      title: "Track Health Metrics",
      description:
          "Monitor your health stats including sleep, water intake, and heart rate",
      imagePath: "assets/images/Onboarding3.png",
      color: AppColors.primaryLightBlue,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      await _authController.completeOnboarding();

      // Navigate to welcome screen using GetX
      Get.offAllNamed(Routes.welcome);
    }
  }

  void _skip() async {
    // Mark onboarding as completed
    await _authController.completeOnboarding();

    // Navigate to welcome screen using GetX
    Get.offAllNamed(Routes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPageWidget(page: _pages[index]);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child:
                _currentPage < _pages.length - 1
                    ? TextButton(
                      onPressed: _skip,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 20 : 10,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? _pages[_currentPage].color
                                : AppColors.textLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Next/Get Started button
                PrimaryButton(
                  text:
                      _currentPage < _pages.length - 1 ? "Next" : "Get Started",
                  onPressed: _nextPage,
                  gradient: LinearGradient(
                    colors: [
                      _pages[_currentPage].color,
                      _pages[_currentPage].color.withOpacity(0.8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Page Data Model
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}

// Onboarding Page Widget
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page image
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.only(top: 100),
              child: Image.asset(page.imagePath, fit: BoxFit.contain),
            ),
          ),

          // Content
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Title
                Text(
                  page.title,
                  style: AppTextStyles.heading2.copyWith(color: page.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  page.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
