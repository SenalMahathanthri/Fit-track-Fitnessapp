// lib/common_widget/water_intake_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'simple_animation_progress_bar.dart';
import 'dotted_dashed_line.dart';

class WaterIntakeCard extends StatelessWidget {
  final List waterEntries;
  final String totalIntake;
  final double progress;
  final VoidCallback? onAddPressed;

  const WaterIntakeCard({
    super.key,
    required this.waterEntries,
    required this.totalIntake,
    required this.progress,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

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
        children: [
          // Header with title and add button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Water Intake",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: AppColors.blueGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                        );
                      },
                      child: Text(
                        "$totalIntake Liters",
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Add water button
              InkWell(
                onTap: onAddPressed,
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.blueGradient,
                    ),
                    borderRadius: BorderRadius.circular(17.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLightBlue.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Progress and timeline
          Row(
            children: [
              SimpleAnimationProgressBar(
                height: media.width * 0.5,
                width: media.width * 0.05,
                backgroundColor: Colors.grey.shade100,
                foregrondColor: Colors.transparent,
                ratio: progress,
                direction: Axis.vertical,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(seconds: 2),
                borderRadius: BorderRadius.circular(15),
                gradientColor: const LinearGradient(
                  colors: AppColors.blueGradient,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Real time updates",
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Water intake timeline
                    Column(
                      children:
                          waterEntries.map((entry) {
                            bool isLast = entry == waterEntries.last;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline dot and line
                                Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryPink
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    if (!isLast)
                                      DottedDashedLine(
                                        height: media.width * 0.12,
                                        width: 0,
                                        dashColor: AppColors.secondaryPink
                                            .withOpacity(0.3),
                                        axis: Axis.vertical,
                                        dashWidth: 2,
                                        dashGap: 3,
                                      ),
                                  ],
                                ),

                                const SizedBox(width: 10),

                                // Time and amount
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry["title"].toString(),
                                        style: const TextStyle(
                                          color: AppColors.gray,
                                          fontSize: 12,
                                        ),
                                      ),

                                      ShaderMask(
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) {
                                          return const LinearGradient(
                                            colors: AppColors.purpleGradient,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(
                                            Rect.fromLTRB(
                                              0,
                                              0,
                                              bounds.width,
                                              bounds.height,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          entry["subtitle"].toString(),
                                          style: TextStyle(
                                            color: AppColors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: isLast ? 0 : 15),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
