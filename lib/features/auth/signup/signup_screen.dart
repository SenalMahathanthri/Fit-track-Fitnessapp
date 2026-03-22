import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/custom_dropdown.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../../../core/routes/app_pages.dart';
import '../../../data/models/user_model.dart' as app_user;
import '../auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _goalTypeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  // Get the auth controller
  final AuthController _authController = Get.put(AuthController());

  bool _isLoading = false;
  List<app_user.UserModel> _coaches = [];
  String? _selectedCoachId;
  bool _isLoadingCoaches = true;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    final coaches = await _authController.getAvailableCoaches();
    if (mounted) {
      setState(() {
        _coaches = coaches;
        _isLoadingCoaches = false;
        if (_coaches.isNotEmpty) {
          _selectedCoachId = _coaches.first.uid;
        }
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      if (_selectedCoachId == null) {
        _authController.showErrorMessage("Please select a coach");
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create user data map
        final userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'height': _heightController.text,
          'height_unit': 'cm',
          'weight': _weightController.text,
          'weight_unit': 'kg',
          'gender': _genderController.text,
          'age': _ageController.text,
          'age_unit': 'years',
          'goalType': _goalTypeController.text,
          'coachId': _selectedCoachId,
        };

        // Use auth controller to register
        final success = await _authController.register(
          email: _emailController.text,
          password: _passwordController.text,
          userData: userData,
        );

        if (success) {
          _authController.showSuccessMessage(
            "Account created! Please check your email to verify your account.",
          );
          // Navigation is handled by auth controller
        } else {
          print(
            "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ${_authController.errorMessage}",
          );
          _authController.showErrorMessage(_authController.errorMessage.value);
        }
      } catch (e) {
        print(
          "############################################################################################ $e",
        );
        _authController.showErrorMessage("Registration failed: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (!_agreeToTerms) {
      _authController.showErrorMessage(
        "Please agree to the Terms and Conditions",
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _goalTypeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine layout based on screen width
    final bool isTablet = screenWidth >= 600;
    final bool isDesktop = screenWidth >= 900;

    // Calculate responsive padding and spacing
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final verticalSpacing = screenHeight * 0.02; // 2% of screen height

    // Max width for content (looks better on large screens)
    final maxContentWidth =
        isDesktop ? 600.0 : (isTablet ? 500.0 : double.infinity);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: verticalSpacing),

                      // Register header - responsive font sizes
                      Text(
                        "Create Account",
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: (screenWidth * 0.08).clamp(24.0, 32.0),
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 0.5),

                      Text(
                        "Sign up to start your fitness journey today",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 2),

                      // Personal Information Section
                      _buildSectionTitle("Personal Information", screenWidth),

                      SizedBox(height: verticalSpacing),

                      // Personal Info Fields with responsive layout
                      if (isTablet)
                        _buildTabletLayout()
                      else
                        _buildMobileLayout(),

                      SizedBox(height: verticalSpacing * 2),

                      // Account Information Section
                      _buildSectionTitle("Account Information", screenWidth),

                      SizedBox(height: verticalSpacing),

                      // Email input
                      _buildEmailField(),

                      SizedBox(height: verticalSpacing),

                      // Password fields - responsive layout
                      if (isTablet)
                        Row(
                          children: [
                            Expanded(child: _buildPasswordField()),
                            SizedBox(width: verticalSpacing),
                            Expanded(child: _buildConfirmPasswordField()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildPasswordField(),
                            SizedBox(height: verticalSpacing),
                            _buildConfirmPasswordField(),
                          ],
                        ),

                      SizedBox(height: verticalSpacing * 2),

                      // Terms and conditions
                      _buildTermsCheckbox(screenWidth),

                      SizedBox(height: verticalSpacing * 2),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                                : PrimaryButton(
                                  text: "Register",
                                  onPressed: _signUp,
                                ),
                      ),

                      SizedBox(height: verticalSpacing * 1.5),

                      // Login link
                      _buildLoginLink(screenWidth),

                      SizedBox(height: verticalSpacing * 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section title builder
  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // Tablet/Desktop layout - multiple columns
  Widget _buildTabletLayout() {
    final spacing = MediaQuery.of(context).size.height * 0.02;

    return Column(
      children: [
        // Row 1: Name and Phone
        Row(
          children: [
            Expanded(child: _buildNameField()),
            SizedBox(width: spacing),
            Expanded(child: _buildPhoneField()),
          ],
        ),
        SizedBox(height: spacing),

        // Row 2: Height and Weight
        Row(
          children: [
            Expanded(child: _buildHeightField()),
            SizedBox(width: spacing),
            Expanded(child: _buildWeightField()),
          ],
        ),
        SizedBox(height: spacing),

        // Row 3: Age, Gender, and Goal
        Row(
          children: [
            Expanded(flex: 1, child: _buildAgeField()),
            SizedBox(width: spacing),
            Expanded(flex: 1, child: _buildGenderField()),
            SizedBox(width: spacing),
            Expanded(flex: 2, child: _buildGoalField()),
          ],
        ),
        SizedBox(height: spacing),

        // Row 4: Coach
        Row(
          children: [
            Expanded(child: _buildCoachField()),
          ],
        ),
      ],
    );
  }

  // Mobile layout - single column
  Widget _buildMobileLayout() {
    final spacing = MediaQuery.of(context).size.height * 0.02;

    return Column(
      children: [
        _buildNameField(),
        SizedBox(height: spacing),
        _buildPhoneField(),
        SizedBox(height: spacing),
        _buildHeightField(),
        SizedBox(height: spacing),
        _buildWeightField(),
        SizedBox(height: spacing),
        _buildAgeField(),
        SizedBox(height: spacing),
        _buildGenderField(),
        SizedBox(height: spacing),
        _buildGoalField(),
        SizedBox(height: spacing),
        _buildCoachField(),
      ],
    );
  }

  // Individual field builders
  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      label: "Full Name",
      hintText: "Enter your full name",
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your name";
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      label: "Phone Number",
      hintText: "Enter your phone number",
      prefixIcon: Icons.phone_android,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your phone number";
        }
        if (value.length < 10) {
          return "Please enter a valid phone number";
        }
        return null;
      },
    );
  }

  Widget _buildHeightField() {
    return CustomTextField(
      controller: _heightController,
      label: "Height (cm)",
      hintText: "Enter your height in cm",
      prefixIcon: Icons.height_outlined,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your height";
        }
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    return CustomTextField(
      controller: _weightController,
      label: "Weight (kg)",
      hintText: "Enter your weight in kg",
      prefixIcon: Icons.line_weight_outlined,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your weight";
        }
        return null;
      },
    );
  }

  Widget _buildAgeField() {
    return CustomTextField(
      controller: _ageController,
      label: "Age (years)",
      hintText: "Enter your age",
      prefixIcon: Icons.person_outlined,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your age";
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return CustomDropdownField(
      controller: _genderController,
      label: "Gender",
      prefixIcon: Icons.person_outline,
      hintText: "Select your gender",
      items: const ["Male", "Female"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select your gender";
        }
        return null;
      },
      backgroundColor: Colors.white,
      borderColor: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildGoalField() {
    return CustomDropdownField(
      controller: _goalTypeController,
      label: "Fitness Goal",
      prefixIcon: Icons.fitness_center_outlined,
      hintText: "Select your fitness goal",
      items: const ["FatBurn", "WeightGain"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select your fitness goal";
        }
        return null;
      },
      backgroundColor: Colors.white,
      borderColor: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildCoachField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Select Coach",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCoachId,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: _isLoadingCoaches 
                ? const Text("Loading coaches...") 
                : const Text("Select your coach"),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray),
            dropdownColor: Colors.white,
            items: _coaches.map((coach) {
              return DropdownMenuItem<String>(
                value: coach.uid,
                child: Text(coach.name.isNotEmpty ? coach.name : "Unknown Coach", 
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCoachId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select your coach";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      label: "Email",
      hintText: "Enter your email address",
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!GetUtils.isEmail(value)) {
          return "Please enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      label: "Password",
      hintText: "Create a password",
      prefixIcon: Icons.lock_outline,
      isPassword: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a password";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      label: "Confirm Password",
      hintText: "Confirm your password",
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
    );
  }

  Widget _buildTermsCheckbox(double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: (screenWidth * 0.03).clamp(12.0, 14.0),
              ),
              children: [
                const TextSpan(text: "By signing up, you agree to our "),
                TextSpan(
                  text: "Terms of Service",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: (screenWidth * 0.03).clamp(12.0, 14.0),
                  ),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: (screenWidth * 0.03).clamp(12.0, 14.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(double screenWidth) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.offAllNamed(Routes.login);
        },
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: (screenWidth * 0.035).clamp(14.0, 16.0),
            ),
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Login",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: (screenWidth * 0.035).clamp(14.0, 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
