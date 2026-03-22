// lib/core/utils/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  // Success Snackbar
  static void showSuccess({
    required String message,
    String title = 'Success',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      shouldIconPulse: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Error Snackbar
  static void showError({
    required String message,
    String title = 'Error',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Warning Snackbar
  static void showWarning({
    required String message,
    String title = 'Warning',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.black),
      shouldIconPulse: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Info Snackbar
  static void showInfo({
    required String message,
    String title = 'Info',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppColors.primaryBlue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      shouldIconPulse: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Loading Snackbar with custom duration
  static void showLoading({
    String message = 'Loading...',
    String title = 'Please wait',
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(
        days: 1,
      ), // Long duration until manually dismissed
      icon: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 3,
      ),
      isDismissible: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Dismiss the current snackbar
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }
}
