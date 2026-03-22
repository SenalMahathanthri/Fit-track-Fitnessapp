import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_pages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/inputs/custom_text_field.dart';
import '../auth/auth_controller.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool notifications = true;
  bool isEditing = false;

  // Controllers for editing
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  final programController = TextEditingController();

  // Account menu items
  List accountArr = [
    {"icon": Icons.person, "name": "Personal Data", "tag": "1"},
    {"icon": Icons.emoji_events, "name": "Achievement", "tag": "2"},
    {"icon": Icons.history, "name": "Activity History", "tag": "3"},
    {"icon": Icons.fitness_center, "name": "Workout Progress", "tag": "4"},
  ];

  // Settings/Other menu items
  List otherArr = [
    {"icon": Icons.headset_mic, "name": "Contact Us", "tag": "5"},
    {"icon": Icons.privacy_tip, "name": "Privacy Policy", "tag": "6"},
    //{"icon": Icons.settings, "name": "Settings", "tag": "7"},
    {
      "icon": Icons.logout,
      "name": "Log Out",
      "tag": "8",
      "color": AppColors.error,
    },
  ];

  // Program Types
  String? selectedProgram;
  final List<String> programOptions = ['FatBurn', 'WeightGain'];

  @override
  void initState() {
    super.initState();
    // Fetch the latest user data when profile screen opens
    final authController = Get.find<AuthController>();
    authController.fetchUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(media.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(media),

                SizedBox(height: media.height * 0.025),

                // Profile Stats
                _buildProfileStats(media),
                SizedBox(height: media.height * 0.025),

                // Notification Section
                _buildSectionContainer(
                  "Notification",
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Pop-up Notification",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Toggle Switch
                        Switch(
                          value: notifications,
                          onChanged: (value) {
                            setState(() {
                              notifications = value;
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: media.height * 0.025),

                // Other Settings Section
                _buildSectionContainer(
                  "Other",
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: otherArr.length,
                    itemBuilder: (context, index) {
                      var item = otherArr[index] as Map? ?? {};
                      return _buildSettingItem(
                        item["name"].toString(),
                        item["icon"] as IconData,
                        item.containsKey("color")
                            ? (item["color"] as Color)
                            : AppColors.primaryBlue,
                        onTap: () {
                          if (item["tag"] == "8") {
                            // Handle logout
                            _showLogoutConfirmation(context);
                          } else if (item["tag"] == "5") {
                            // Navigate to Contact Us
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUsScreen(),
                              ),
                            );
                          } else if (item["tag"] == "6") {
                            // Navigate to Privacy Policy
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PrivacyPolicyScreen(),
                              ),
                            );
                          } else {
                            // Handle other option navigation
                          }
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: media.height * 0.05),

                // Version info
                const Center(
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ),

                SizedBox(height: media.height * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Size media) {
    return isEditing
        ? _buildEditableProfileHeader(media)
        : _buildViewOnlyProfileHeader(media);
  }

  Widget _buildViewOnlyProfileHeader(Size media) {
    final authController = Get.find<AuthController>();
    return Obx(
      () => Row(
        children: [
          // Profile Picture
          Container(
            width: media.width * 0.18,
            height: media.width * 0.18,
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: media.width * 0.1,
                color: AppColors.primaryBlue,
              ),
            ),
          ),

          SizedBox(width: media.width * 0.04),

          // Name and Program info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authController.user.value?.name ?? '-',
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  authController.user.value?.goalType ?? '-',
                  style: const TextStyle(color: AppColors.gray, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  authController.user.value?.email ?? '-',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // Edit Button
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                final authController = Get.find<AuthController>();

                // Get user's current goal type (or default to first option if null/empty)
                String currentGoalType =
                    authController.user.value?.goalType ?? '';

                // Make sure selectedProgram is in programOptions, otherwise default to first option
                String initialProgram = currentGoalType;
                if (currentGoalType.isEmpty ||
                    !programOptions.contains(currentGoalType)) {
                  initialProgram =
                      programOptions.isNotEmpty ? programOptions[0] : '';
                }

                setState(() {
                  nameController.text = authController.user.value?.name ?? '';
                  emailController.text = authController.user.value?.email ?? '';
                  programController.text = initialProgram;
                  selectedProgram = initialProgram;
                  heightController.text =
                      authController.user.value?.height.toString() ?? '';
                  weightController.text =
                      authController.user.value?.weight.toString() ?? '';
                  ageController.text =
                      authController.user.value?.age.toString() ?? '';
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileHeader(Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture with edit option
        Center(
          child: Stack(
            children: [
              Container(
                width: media.width * 0.25,
                height: media.width * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: media.width * 0.15,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: media.height * 0.025),

        // Name field
        CustomTextField(
          label: "Full Name",
          hintText: "Enter your full name",
          controller: nameController,
          prefixIcon: Icons.person_outline,
        ),

        SizedBox(height: media.height * 0.015),

        // Email field
        CustomTextField(
          label: "Email",
          hintText: "Enter your email",
          controller: emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: media.height * 0.015),

        // Program dropdown styled to match CustomTextField
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Program",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gray.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedProgram,
                isExpanded: true,
                hint: const Text("Select a program"),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.fitness_center_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: AppTextStyles.bodyLarge,
                items:
                    programOptions
                        .map(
                          (program) => DropdownMenuItem(
                            value: program,
                            child: Text(program),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedProgram = value;
                      programController.text = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileStats(Size media) {
    return isEditing
        ? _buildEditableProfileStats(media)
        : _buildViewOnlyProfileStats(media);
  }

  Widget _buildViewOnlyProfileStats(Size media) {
    final authController = Get.find<AuthController>();

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "Height",
              "${authController.user.value?.height.toString() ?? '-'} cm",
              Icons.height,
              AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: media.width * 0.03),
          Expanded(
            child: _buildStatCard(
              "Weight",
              "${authController.user.value?.weight.toString() ?? '-'} kg",
              Icons.monitor_weight,
              AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: media.width * 0.03),
          Expanded(
            child: _buildStatCard(
              "Age",
              "${authController.user.value?.age.toString() ?? '-'} yrs",
              Icons.calendar_today,
              AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileStats(Size media) {
    return Column(
      children: [
        const Text(
          "Personal Stats",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: media.height * 0.015),

        // Height, weight, age in a row
        Row(
          children: [
            // Height field
            Expanded(
              child: CustomTextField(
                label: "Height (cm)",
                hintText: "cm",
                controller: heightController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: media.width * 0.03),

            // Weight field
            Expanded(
              child: CustomTextField(
                label: "Weight (Kg)",
                hintText: "kg",
                controller: weightController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: media.width * 0.03),

            // Age field
            Expanded(
              child: CustomTextField(
                label: "Age (Yrs)",
                hintText: "yrs",
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),

        SizedBox(height: media.height * 0.025),

        // Save button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Save changes
              final authController = Get.find<AuthController>();
              final updatedData = {
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'goalType': selectedProgram,
                'height': heightController.text.trim(),
                'weight': weightController.text.trim(),
                'age': ageController.text.trim(),
              };

              // Update Firebase and refresh local user model
              await authController.updateUserProfile(updatedData);

              final user = authController.user.value;
              setState(() {
                nameController.text = user?.name ?? '';
                emailController.text = user?.email ?? '';
                programController.text = user?.goalType ?? '';
                heightController.text = user?.height.toString() ?? '';
                weightController.text = user?.weight.toString() ?? '';
                ageController.text = user?.age.toString() ?? '';
                isEditing = false;
              });

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: title == "Log Out" ? AppColors.error : AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Get the AuthController instance
                  final AuthController authController = Get.put(
                    AuthController(),
                  );

                  // Call logout method and navigate to login screen
                  authController.logout().then((_) {
                    Get.offAllNamed(Routes.login);
                  });
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
