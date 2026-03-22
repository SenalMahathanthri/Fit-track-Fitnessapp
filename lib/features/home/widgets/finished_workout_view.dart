// lib/view/home/finished_workout_view.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/buttons/round_button.dart';

class FinishedWorkoutView extends StatefulWidget {
  const FinishedWorkoutView({super.key});

  @override
  State<FinishedWorkoutView> createState() => _FinishedWorkoutViewState();
}

class _FinishedWorkoutViewState extends State<FinishedWorkoutView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Success illustration
              Image.asset(
                "assets/img/complete_workout.png",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),

              const SizedBox(height: 20),

              // Congratulations text
              const Text(
                "Congratulations, You Have Finished Your Workout",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              // Motivational quote
              const Text(
                "Exercise is king and nutrition is queen. Combine the two and you will have a kingdom",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gray, fontSize: 12),
              ),

              const SizedBox(height: 8),

              // Quote attribution
              const Text(
                "-Jack Lalanne",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gray, fontSize: 12),
              ),

              // Workout stats summary
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Duration
                    _buildStatColumn("24", "Minutes", AppColors.primaryBlue),

                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.gray.withOpacity(0.3),
                    ),

                    // Calories
                    _buildStatColumn(
                      "180",
                      "Calories",
                      AppColors.secondaryPurple,
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.gray.withOpacity(0.3),
                    ),

                    // Exercises
                    _buildStatColumn(
                      "12",
                      "Exercises",
                      AppColors.primaryLightBlue,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Back to home button
              RoundButton(
                title: "Back To Home",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
      ],
    );
  }
}
