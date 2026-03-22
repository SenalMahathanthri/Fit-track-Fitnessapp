// lib/views/widgets/custom_card.dart
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showArrow;

  const CustomCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.iconColor,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primaryBlue).withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  if (showArrow && onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: AppTextStyles.statValue),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyles.statLabel),
            ],
          ),
        ),
      ),
    );
  }
}
