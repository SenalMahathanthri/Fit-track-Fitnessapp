// lib/core/services/error_handling_service.dart
import 'package:get/get.dart';
import '../widgets/snackbar.dart';

class ErrorHandlingService extends GetxService {
  // Track if there's an error already being displayed
  final RxBool _isErrorShowing = false.obs;

  // Handle different error types and show appropriate messages
  void handleError(dynamic error, {String? customMessage}) {
    // Don't show multiple errors simultaneously
    if (_isErrorShowing.value) return;

    _isErrorShowing.value = true;

    String errorMessage = customMessage ?? 'An unexpected error occurred.';

    // Handle different error types
    if (error is String) {
      errorMessage = error;
    } else if (error is Map && error.containsKey('message')) {
      errorMessage = error['message'].toString();
    } else if (error is Exception) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    // Show the error
    AppSnackbar.showError(message: errorMessage);

    // Reset error showing flag after a delay
    Future.delayed(const Duration(seconds: 4), () {
      _isErrorShowing.value = false;
    });
  }

  // Handle success messages
  void handleSuccess(String message) {
    AppSnackbar.showSuccess(message: message);
  }

  // Handle warning messages
  void handleWarning(String message) {
    AppSnackbar.showWarning(message: message);
  }

  // Handle information messages
  void handleInfo(String message) {
    AppSnackbar.showInfo(message: message);
  }

  // Handle loading state
  void showLoading({String message = 'Loading...'}) {
    AppSnackbar.showLoading(message: message);
  }

  // Hide loading state
  void hideLoading() {
    AppSnackbar.dismiss();
  }
}
