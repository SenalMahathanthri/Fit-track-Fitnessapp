import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Heading Styles
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Body Text Styles
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.5,
  );

  // Button Text Styles
  static TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Label Styles
  static TextStyle label = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  // Value Styles for stats
  static TextStyle statValue = GoogleFonts.poppins(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle statLabel = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );
}
