// lib/common_widget/round_button.dart
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum RoundButtonType {
  bgGradient,
  bgSGradient,
  textGradient,
  bgColor,
  bgOutline,
}

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final VoidCallback onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final double width;
  final double height;
  final Color? color;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.bgGradient,
    required this.onPressed,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
    this.width = double.infinity,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: getBoxDecoration(),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: getTitleText(),
      ),
    );
  }

  BoxDecoration getBoxDecoration() {
    switch (type) {
      case RoundButtonType.bgGradient:
        return BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLightBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case RoundButtonType.bgSGradient:
        return BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.purpleGradient),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case RoundButtonType.bgColor:
        return BoxDecoration(
          color: color ?? AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.primaryBlue).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case RoundButtonType.bgOutline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: color ?? AppColors.primaryBlue, width: 1),
          borderRadius: BorderRadius.circular(height / 2),
        );
      default:
        return BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLightBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Widget getTitleText() {
    switch (type) {
      case RoundButtonType.textGradient:
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: AppColors.blueGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        );
      case RoundButtonType.bgOutline:
        return Text(
          title,
          style: TextStyle(
            color: color ?? AppColors.primaryBlue,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        );
      default:
        return Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        );
    }
  }
}
