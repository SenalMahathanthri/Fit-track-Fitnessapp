// lib/common_widget/today_workout_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TodayWorkoutCard extends StatelessWidget {
  final Map wObj;
  final VoidCallback? onPressed;

  const TodayWorkoutCard({super.key, required this.wObj, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Row(
        children: [
          // Workout Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              wObj["image"].toString(),
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          // Workout Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Name
                Text(
                  wObj["name"].toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                // Workout Details (Exercises)
                Text(
                  wObj["exercises"].toString(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                // Workout Time and Calories Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time and calories text
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Duration: ",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: "${wObj["time"]} min",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: " • ",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: "${wObj["kcal"]} kcal",
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Start button
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
