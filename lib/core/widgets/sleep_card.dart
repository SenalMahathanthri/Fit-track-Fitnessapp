// lib/common_widget/sleep_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Updated import path

class SleepCard extends StatelessWidget {
  final String duration;
  final String quality;
  final String timeRange;
  final String imgPath;
  final VoidCallback? onViewDetails;

  const SleepCard({
    super.key,
    required this.duration,
    required this.quality,
    required this.timeRange,
    this.imgPath = "assets/img/sleep_grap.png",
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sleep title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sleep",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors:
                                AppColors
                                    .blueGradient, // Updated from primaryG to blueGradient
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                          );
                        },
                        child: Text(
                          duration,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (quality.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightBlue.withOpacity(
                              0.3,
                            ), // Updated from primaryColor2
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            quality,
                            style: const TextStyle(
                              color:
                                  AppColors
                                      .primaryLightBlue, // Updated from primaryColor2
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // View details button
              InkWell(
                onTap: onViewDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.blueGradient,
                    ), // Updated from primaryG
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Sleep time range
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.gray,
              ),
              const SizedBox(width: 5),
              Text(
                timeRange,
                style: const TextStyle(color: AppColors.gray, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Sleep graph
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imgPath,
              width: double.maxFinite,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }
}
