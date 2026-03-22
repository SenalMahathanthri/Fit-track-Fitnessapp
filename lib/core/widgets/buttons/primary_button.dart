import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool isOutlined;
  final Gradient? gradient;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 55,
    this.isOutlined = false,
    this.gradient,
    this.backgroundColor,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient:
            !isOutlined
                ? gradient ??
                    const LinearGradient(
                      colors: AppColors.blueGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                : null,
        color: isOutlined ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border:
            isOutlined
                ? Border.all(color: AppColors.primaryBlue, width: 2)
                : null,
        boxShadow:
            !isOutlined
                ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isOutlined ? AppColors.primaryBlue : Colors.white,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: AppTextStyles.buttonLarge.copyWith(
                color: isOutlined ? AppColors.primaryBlue : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
