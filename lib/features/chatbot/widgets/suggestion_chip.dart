import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SuggestionChip extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Text(
            question,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
