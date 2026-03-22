// lib/views/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/auth_controller.dart';
import '../theme/app_text_styles.dart';
import '../../core/routes/app_pages.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLogoutButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showLogoutButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      title: Text(title, style: AppTextStyles.heading3),
      actions: [
        ...?actions,
        if (showLogoutButton)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authController),
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back(); // Close dialog
                await authController.logout();
                Get.offAllNamed(Routes.welcome);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
