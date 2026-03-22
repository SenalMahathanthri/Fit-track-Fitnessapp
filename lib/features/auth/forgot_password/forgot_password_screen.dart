import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.forgotPassword(
        _emailController.text,
      );

      if (success) {
        setState(() {
          _emailSent = true;
        });

        _authController.showSuccessMessage(
          'Password reset link sent to ${_emailController.text}',
        );
      } else {
        _authController.showErrorMessage(_authController.errorMessage.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_outlined,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "Forgot Password?",
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _emailSent
                        ? "We've sent a password reset link to your email address. Please check your inbox."
                        : "Enter your email address below and we'll send you a link to reset your password.",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  if (!_emailSent) ...[
                    // Email input
                    CustomTextField(
                      controller: _emailController,
                      label: "Email",
                      hintText: "Enter your email address",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!GetUtils.isEmail(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Send button
                    Obx(
                      () =>
                          _authController.isLoading.value
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue,
                                ),
                              )
                              : PrimaryButton(
                                text: "Send Reset Link",
                                onPressed: _sendResetEmail,
                              ),
                    ),
                  ] else ...[
                    // Success state
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: Colors.green[600],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resend button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _emailSent = false;
                        });
                      },
                      child: Text(
                        "Didn't receive the email? Try again",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Back to login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Back to Login",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
