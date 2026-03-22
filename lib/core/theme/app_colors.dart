// lib/common/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF4A72FF); // Deep, vibrant blue
  static const Color primaryLightBlue = Color(0xFF7BA0FF); 
  static const Color secondaryPurple = Color(0xFF9854FF); // Rich purple
  static const Color secondaryPink = Color(0xFFFF5EBD); // Vibrant pink
  static const Color black = Color(0xFF1A1D26); // Soft charcoal black
  static const Color gray = Color(0xFF6B7280); // Cool gray
  static const Color white = Color(0xFFFFFFFF);

  // Gradient Colors for backgrounds
  static const List<Color> blueGradient = [
    Color(0xFF4A72FF),
    Color(0xFF7BA0FF),
  ];
  static const List<Color> purpleGradient = [
    Color(0xFF9854FF),
    Color(0xFFFF5EBD),
  ];

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF9FAFB); // Very light, cool gray
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Very dark gray for headings
  static const Color textSecondary = Color(0xFF6B7280); // Standard gray body
  static const Color textLight = Color(0xFF9CA3AF); // Muted text

  // Status and Action Colors
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue
}
