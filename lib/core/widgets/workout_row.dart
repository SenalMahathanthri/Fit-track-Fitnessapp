// lib/common_widget/workout_row.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WorkoutRow extends StatelessWidget {
  final Map wObj;
  const WorkoutRow({super.key, required this.wObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              wObj["image"].toString(),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["name"].toString(),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${wObj["time"]} min | ${wObj["kcal"]} kcal",
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: media.width * 0.28,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                    ),
                    Container(
                      width:
                          (media.width * 0.28) *
                          (wObj["progress"] as double? ?? 0.0),
                      height: 15,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              wObj["progress"] == 1.0
                                  ? AppColors.blueGradient
                                  : [
                                    AppColors.secondaryPink,
                                    AppColors.secondaryPurple,
                                  ],
                        ),
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                wObj["progress"] == 1.0 ? "Completed" : "In Progress",
                style: TextStyle(
                  color:
                      wObj["progress"] == 1.0
                          ? AppColors.primaryBlue
                          : AppColors.secondaryPurple,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
