// lib/features/auth/forgot_password/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../../../core/routes/app_pages.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would reset the password here

      // Show success message using GetX snackbar
      Get.snackbar(
        "Success",
        "Password reset successfully!",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Navigate back to login using GetX
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(Routes.login); // Clear all screens and go to login
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: IconButton(
                      onPressed: () => Get.back(), // Using GetX for navigation
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Header
                  Text("Reset Password", style: AppTextStyles.heading1),

                  const SizedBox(height: 12),

                  Text(
                    "Create a new, strong password that you don't use for other accounts",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 40),

                  // Password input
                  CustomTextField(
                    controller: _passwordController,
                    label: "New Password",
                    hintText: "Create a new password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a new password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                    onChanged:
                        (_) => setState(
                          () {},
                        ), // Update UI for live requirement checks
                  ),

                  const SizedBox(height: 24),

                  // Confirm Password input
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    hintText: "Confirm your new password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Password requirements
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password requirements:",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRequirementRow(
                          "At least 6 characters",
                          _passwordController.text.length >= 6,
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow(
                          "Contain at least one number",
                          _passwordController.text.contains(RegExp(r'[0-9]')),
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow(
                          "Contain at least one uppercase letter",
                          _passwordController.text.contains(RegExp(r'[A-Z]')),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Reset Password button
                  PrimaryButton(
                    text: "Reset Password",
                    onPressed: _resetPassword,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? AppColors.success : AppColors.textLight,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
