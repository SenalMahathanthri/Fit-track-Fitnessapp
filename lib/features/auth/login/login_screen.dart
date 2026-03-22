import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../../../core/routes/app_pages.dart';
import '../auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Get the auth controller
  final AuthController _authController = Get.put(AuthController());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_emailController.text.toLowerCase() == "admin@gmail.com" &&
            _passwordController.text == "admin123") {
          _authController.showSuccessMessage("Welcome Admin!");
          Get.offAllNamed(Routes.adminDashboard);
          return; // Bypass Firebase Auth for hardcoded admin
        }
        final success = await _authController.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!success) {
          // Show error message
          _authController.showErrorMessage(_authController.errorMessage.value);
        }
        // Navigation is handled by auth controller's stream listener
      } catch (e) {
        _authController.showErrorMessage("Login failed: ${e.toString()}");
      }
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
                      onPressed: () => Get.back(),
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

                  // Login header
                  Text("Welcome Back!", style: AppTextStyles.heading1),

                  const SizedBox(height: 8),

                  Text(
                    "Log in to your account to continue your fitness journey",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 40),

                  // Email input
                  CustomTextField(
                    controller: _emailController,
                    label: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icons.mail,
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

                  const SizedBox(height: 24),

                  // Password input
                  CustomTextField(
                    controller: _passwordController,
                    label: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Remember me and Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remember me",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Forgot password
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.forgotPassword);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  Obx(
                    () =>
                        _authController.isLoading.value
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                            )
                            : PrimaryButton(text: "Login", onPressed: _login),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or continue with",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.signup);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Register",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
}
