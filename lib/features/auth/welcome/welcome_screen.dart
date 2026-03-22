// lib/features/auth/welcome/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/routes/app_pages.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive sizes
    final logoSize = screenWidth * 0.25; // 25% of screen width
    final titleFontSize = screenWidth * 0.08; // Responsive font size
    final subtitleFontSize = screenWidth * 0.04;
    final imageHeight = screenHeight * 0.35; // 35% of screen height
    final padding = screenWidth * 0.05; // 5% of screen width as padding

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.primaryLightBlue.withOpacity(0.1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top space
                    SizedBox(height: screenHeight * 0.05),

                    // Logo and app name
                    Column(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              logoSize * 0.25,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            size: logoSize * 0.5,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Text(
                          "FitTracker",
                          style: TextStyle(
                            fontSize: titleFontSize.clamp(
                              24.0,
                              40.0,
                            ), // Min 24, Max 40
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Your complete fitness solution",
                          style: TextStyle(
                            fontSize: subtitleFontSize.clamp(
                              14.0,
                              18.0,
                            ), // Min 14, Max 18
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Flexible space
                    const Spacer(),

                    // Illustration
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: imageHeight,
                        maxWidth: screenWidth * 0.8,
                      ),
                      child: Image.asset(
                        'assets/images/WelcomeImg.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Flexible space
                    const Spacer(),

                    // Action buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding.clamp(20.0, 40.0),
                      ),
                      child: Column(
                        children: [
                          PrimaryButton(
                            text: "Login",
                            onPressed: () => Get.toNamed(Routes.login),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          PrimaryButton(
                            text: "Register",
                            onPressed: () => Get.toNamed(Routes.signup),
                            isOutlined: true,
                          ),
                        ],
                      ),
                    ),

                    // Bottom space
                    SizedBox(height: screenHeight * 0.05),

                    // Terms and privacy text
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.04,
                        left: padding.clamp(20.0, 30.0),
                        right: padding.clamp(20.0, 30.0),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: (screenWidth * 0.035).clamp(11.0, 14.0),
                            color: AppColors.textSecondary,
                          ),
                          children: const [
                            TextSpan(text: "By continuing, you agree to our "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
