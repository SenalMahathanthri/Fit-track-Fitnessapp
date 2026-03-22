// lib/features/auth/email_verification/email_verification_screen.dart
import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../main.dart' as AppRoutes;
import '../auth_controller.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthController _authController = Get.put(AuthController());
  bool _isResendingEmail = false;
  final RxInt _timeLeft = 60.obs;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Start auto-checking verification status
    _authController.startEmailVerificationCheck();
    // Start resend timer
    _startResendTimer();
  }

  @override
  void dispose() {
    // Stop checking email verification on dispose
    _authController.stopEmailVerificationCheck();
    super.dispose();
  }

  // Start timer for resend button
  void _startResendTimer() {
    _timeLeft.value = 60;
    _canResend = false;

    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.value > 0) {
        _timeLeft.value--;
      } else {
        _canResend = true;
        timer.cancel();
      }
    });
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() {
      _isResendingEmail = true;
    });

    final success = await _authController.resendEmailVerification();

    setState(() {
      _isResendingEmail = false;
    });

    if (success) {
      _authController.showSuccessMessage(
        'Verification email resent. Please check your inbox.',
      );
      _startResendTimer();
    } else {
      _authController.showErrorMessage(_authController.errorMessage.value);
    }
  }

  // Log out user
  void _logout() async {
    await _authController.logout();
    // Navigation is handled by auth controller's stream listener
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Verify Your Email",
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 50,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                "Verify Your Email Address",
                style: AppTextStyles.heading2.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                "We've sent a verification link to your email address. Please check your inbox and click the link to verify your account.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email address
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sent to",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _authController.firebaseUser.value?.email ??
                                "your email",
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Check inbox button
              PrimaryButton(
                text: "Open Email App",
                onPressed: () async {
                  // This is a simple way to try to open email apps
                  // In a production app, you'd want to use a package like url_launcher
                  // to open specific email apps based on platform
                  _authController.showSuccessMessage(
                    'Please check your email inbox',
                  );
                },
                icon: Icons.mail_outline,
              ),

              const SizedBox(height: 24),

              // Resend email section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the email?",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isResendingEmail
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue,
                          ),
                        ),
                      )
                      : Obx(
                        () => TextButton(
                          onPressed:
                              _canResend ? _resendVerificationEmail : null,
                          child: Text(
                            _canResend
                                ? "Resend"
                                : "Resend (${_timeLeft.value}s)",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  _canResend
                                      ? AppColors.primaryBlue
                                      : AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                ],
              ),

              const SizedBox(height: 16),

              // Already verified link
              TextButton(
                onPressed: () async {
                  // Manually reload user and check verification status
                  // await _authController.re;
                  if (_authController.firebaseUser.value?.emailVerified ??
                      false) {
                    // Already verified, navigate to main
                    Get.offAllNamed(AppRoutes.main as String);
                  } else {
                    // Not verified yet
                    _authController.showErrorMessage(
                      'Email not verified yet. Please check your inbox.',
                    );
                  }
                },
                child: Text(
                  "I've already verified my email",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
