import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/weekly_progress_chart.dart';
import '../../data/models/workout_plan.dart';
import '../../data/models/meal_plan.dart';
import '../chatbot/chatbot.dart';
import '../meal_planner/meal_detail_screen.dart';
import '../meal_planner/widgets/meal_details_screen.dart';
import '../workout_plans/widgets/workout_details_screen.dart';
import '../workout_plans/workout_planner_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _controller.loadUserData();
    _controller.loadTodayWorkouts();
    _controller.loadTodayMeals();
    _controller.loadWaterIntake();
    _controller.startListeners();
  }

  @override
  void dispose() {
    _controller.stopListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        tooltip: 'Chat with FitBot',
        child: const Icon(Icons.chat_outlined),
      ),
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: _controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with welcome and user info
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                      vertical: media.height * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back,",
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _controller.user.value?.name ?? "User",
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // BMI and Points Section
                  if (_controller.user.value != null)
                    _buildBmiAndPointsSection(media),
                  SizedBox(height: media.height * 0.02),
                  // Quick action buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                    ),
                    child: _buildQuickActionButtons(media),
                  ),
                  SizedBox(height: media.height * 0.025),
                  // Today's Reminders section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                    ),
                    child: const Text(
                      "Today's Reminders",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: media.height * 0.01),
                  // Horizontal scrollable reminders
                  SizedBox(
                    height: media.height * 0.13,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: media.width * 0.05,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: _buildRemindersList(media),
                    ),
                  ),
                  SizedBox(height: media.height * 0.025),
                  // Activity stats
                  _buildActivityStatsSection(media),
                  SizedBox(height: media.height * 0.025),
                  // Today's workouts
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Workouts",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const WorkoutPlannerScreen());
                          },
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Today's workout list view
                  _buildTodayWorkouts(media),
                  SizedBox(height: media.height * 0.025),
                  // Today's Meals section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Meals",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const MealPlannerScreen());
                          },
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Today's meals list view
                  _buildTodayMeals(media),
                  SizedBox(height: media.height * 0.025),
                  // Weekly Progress Chart
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: media.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Workout Progress",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: media.height * 0.01),
                        WeeklyProgressChart(
                          height: media.width * 0.5,
                          workoutGradientColors: [
                            AppColors.primaryLightBlue.withOpacity(0.5),
                            AppColors.primaryBlue.withOpacity(0.5),
                          ],
                          targetGradientColors: [
                            AppColors.secondaryPink.withOpacity(0.5),
                            AppColors.secondaryPurple.withOpacity(0.5),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.height * 0.1),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBmiAndPointsSection(Size media) {
    // Calculate BMI if user data exists
    final user = _controller.user.value!;
    final bmi = user.calculateBMI();
    final bmiCategory = user.getBMICategory();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: media.width * 0.05),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.blueGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // BMI information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your BMI",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      bmi != null ? bmi.toStringAsFixed(1) : "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "($bmiCategory)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 50, width: 1, color: Colors.white.withOpacity(0.3)),
          // Points information
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Points",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 6),
                      Obx(
                        () => Text(
                          "${_controller.userPoints.value}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(Size media) {
    return Container(
      margin: EdgeInsets.only(top: media.height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickActionButton(
            title: "Start\nWorkout",
            icon: Icons.fitness_center,
            color: AppColors.primaryBlue,
            onTap: () {
              Get.to(
                () => const WorkoutPlannerScreen(),
                transition: Transition.rightToLeft,
              );
            },
            media: media,
          ),
          _buildQuickActionButton(
            title: "Add\nMeal",
            icon: Icons.restaurant,
            color: AppColors.secondaryPurple,
            onTap: () {
              Get.to(
                () => const MealPlannerScreen(),
                transition: Transition.rightToLeft,
              );
            },
            media: media,
          ),
          _buildQuickActionButton(
            title: "Drink\nWater",
            icon: Icons.water_drop,
            color: AppColors.primaryLightBlue,
            onTap: () {
              _showWaterIntakeDialog(context);
            },
            media: media,
          ),
          _buildQuickActionButton(
            title: "Sleep\nTrack",
            icon: Icons.bedtime,
            color: AppColors.secondaryPink,
            onTap: () {
              // Show a message that this is sample data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sleep tracking feature coming soon!"),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            media: media,
          ),
        ],
      ),
    );
  }

  void _showWaterIntakeDialog(BuildContext context) {
    // Use StatefulBuilder to manage state within the dialog
    double waterAmount = 250.0; // Default amount in ml
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log Water Intake'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${waterAmount.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: waterAmount,
                    min: 50.0,
                    max: 1000.0,
                    divisions: 19,
                    activeColor: AppColors.primaryBlue,
                    inactiveColor: AppColors.primaryBlue.withOpacity(0.2),
                    onChanged: (value) {
                      setDialogState(() {
                        waterAmount = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWaterAmountButton(100, waterAmount, (value) {
                        setDialogState(() {
                          waterAmount = value;
                        });
                      }),
                      _buildWaterAmountButton(250, waterAmount, (value) {
                        setDialogState(() {
                          waterAmount = value;
                        });
                      }),
                      _buildWaterAmountButton(500, waterAmount, (value) {
                        setDialogState(() {
                          waterAmount = value;
                        });
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: () {
                    // Add water intake
                    _controller.addWaterIntake(waterAmount.toInt());
                    // Close dialog
                    Navigator.of(context).pop();
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ${waterAmount.toInt()} ml of water',
                        ),
                        backgroundColor: AppColors.primaryBlue,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWaterAmountButton(
    int amount,
    double currentAmount,
    Function(double) onTap,
  ) {
    bool isSelected = currentAmount == amount;
    return InkWell(
      onTap: () => onTap(amount.toDouble()),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$amount ml',
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRemindersList(Size media) {
    // Custom reminders based on user goals and data
    List<Map<String, dynamic>> reminders = [
      {
        "title": "Daily Workout",
        "time": "Morning",
        "icon": Icons.fitness_center,
        "color": AppColors.primaryBlue,
        "tip": "30 min cardio improves heart health",
      },
      {
        "title": "Drink Water",
        "time": "Every hour",
        "icon": Icons.water_drop,
        "color": AppColors.primaryLightBlue,
        "tip": "Aim for 8 glasses daily",
      },
      {
        "title": "Eat Protein",
        "time": "With meals",
        "icon": Icons.restaurant,
        "color": AppColors.secondaryPurple,
        "tip": "0.8g per kg of body weight daily",
      },
      {
        "title": "Get Sleep",
        "time": "10:30 PM",
        "icon": Icons.bedtime,
        "color": AppColors.secondaryPink,
        "tip": "7-9 hours helps recovery",
      },
    ];
    return reminders
        .map((reminder) => _buildReminderCard(reminder, media))
        .toList();
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, Size media) {
    return Container(
      width: media.width * 0.65,
      margin: const EdgeInsets.only(right: 15, bottom: 2), // Added bottom margin for shadow
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (reminder["color"] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              reminder["icon"] as IconData,
              color: reminder["color"] as Color,
              size: 24,
            ),
          ),
          SizedBox(width: media.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reminder["title"].toString(),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder["time"].toString(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder["tip"].toString(),
                  style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStatsSection(Size media) {
    return Obx(() {
      // Sample data for steps and sleep since these are placeholders
      const int sampleSteps = 6500;
      const String sampleSleep = "8h";

      return Container(
        margin: EdgeInsets.symmetric(horizontal: media.width * 0.05),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Today",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: media.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityStatItem(
                  icon: Icons.directions_walk,
                  value: "$sampleSteps",
                  label: "Steps",
                  media: media,
                ),
                _buildActivityStatItem(
                  icon: Icons.local_fire_department,
                  value: "${_controller.totalCalories.value.toInt()}",
                  label: "Calories",
                  media: media,
                ),
                _buildActivityStatItem(
                  icon: Icons.water_drop,
                  value:
                      "${(_controller.waterIntake.value / 1000).toStringAsFixed(1)}L",
                  label: "Water",
                  media: media,
                ),
                _buildActivityStatItem(
                  icon: Icons.bedtime,
                  value: sampleSleep,
                  label: "Sleep",
                  media: media,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActivityStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Size media,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        SizedBox(height: media.height * 0.01),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTodayWorkouts(Size media) {
    return Obx(() {
      if (_controller.isLoadingWorkouts.value) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        );
      }
      if (_controller.todayWorkouts.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "No workouts scheduled for today",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _controller.todayWorkouts.length,
          itemBuilder: (context, index) {
            final workout = _controller.todayWorkouts[index];
            return _buildWorkoutCard(workout, index, media);
          },
        ),
      );
    });
  }

  Widget _buildWorkoutCard(WorkoutPlan workout, int index, Size media) {
    return InkWell(
      onTap: () {
        // Navigate to workout details screen
        Get.to(() => WorkoutDetailsScreen(workoutPlanId: workout.id));
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
            // Workout icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      index % 2 == 0
                          ? AppColors.blueGradient
                          : AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getWorkoutIcon(workout.name),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            // Workout details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout name
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Workout details
                  Text(
                    "${workout.workouts.length} Exercises",
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Time and calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${_calculateTotalDuration(workout)} min • ",
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: "${workout.estimatedCalories.toInt()} kcal",
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action button - Completed or Start
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            if (workout.isFinished) {
                              // Toggle to incomplete if already completed
                              _controller.toggleWorkoutCompletion(
                                workout.id,
                                false,
                              );
                            } else {
                              // Navigate to workout details to start workout
                              Get.to(
                                () => WorkoutDetailsScreen(
                                  workoutPlanId: workout.id,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                workout.isFinished
                                    ? Colors.green
                                    : (index % 2 == 0
                                        ? AppColors.primaryBlue
                                        : AppColors.secondaryPurple),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            workout.isFinished ? "Completed" : "Start",
                            style: const TextStyle(
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
      ),
    );
  }

  int _calculateTotalDuration(WorkoutPlan workout) {
    int totalMinutes = 0;
    for (var exercise in workout.workouts) {
      totalMinutes += exercise.durationMinutes;
    }
    return totalMinutes;
  }

  Widget _buildTodayMeals(Size media) {
    return Obx(() {
      if (_controller.isLoadingMeals.value) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        );
      }
      if (_controller.todayMeals.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "No meals planned for today",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _controller.todayMeals.length,
          itemBuilder: (context, index) {
            final meal = _controller.todayMeals[index];
            return _buildMealCard(meal, index, media);
          },
        ),
      );
    });
  }

  Widget _buildMealCard(MealPlan meal, int index, Size media) {
    final Color mealColor = _getMealColor(meal.type);
    return InkWell(
      onTap: () {
        // Navigate to meal details screen
        Get.to(() => MealDetailsScreen(mealPlan: meal));
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
            // Meal icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: mealColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getMealIcon(meal.type), color: mealColor, size: 30),
            ),
            const SizedBox(width: 15),
            // Meal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal name and type
                  Row(
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: mealColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          meal.type,
                          style: TextStyle(
                            color: mealColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Time
                  Text(
                    meal.time,
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Nutrition info with completion button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nutrient badges
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildNutrientBadge(
                              "C: ${meal.totalCalories.toInt()}",
                              Colors.orange,
                            ),
                            _buildNutrientBadge(
                              "P: ${meal.totalProteins.toInt()}g",
                              AppColors.primaryBlue,
                            ),
                            _buildNutrientBadge(
                              "C: ${meal.totalCarbs.toInt()}g",
                              AppColors.secondaryPurple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Completion status button - Completed checkmark or Complete button
                      meal.isCompleted
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ElevatedButton.icon(
                            onPressed: () {
                              _controller.toggleMealCompletion(meal.id, true);
                            },
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text(
                              "Complete",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mealColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for each workout type
  IconData _getWorkoutIcon(String workoutName) {
    if (workoutName.toLowerCase().contains("full body")) {
      return Icons.accessibility_new;
    } else if (workoutName.toLowerCase().contains("upper body")) {
      return Icons.fitness_center;
    } else if (workoutName.toLowerCase().contains("lower body")) {
      return Icons.directions_run;
    } else if (workoutName.toLowerCase().contains("ab")) {
      return Icons.sports_gymnastics;
    } else {
      return Icons.fitness_center;
    }
  }

  // Helper method to get meal icon based on type
  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.apple;
      default:
        return Icons.restaurant;
    }
  }

  // Helper method to get meal color based on type
  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.primaryBlue;
      case 'dinner':
        return AppColors.secondaryPurple;
      case 'snack':
        return Colors.green;
      default:
        return AppColors.primaryBlue;
    }
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required Function onTap,
    required Size media,
  }) {
    final buttonSize = media.width * 0.17;
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: buttonSize * 0.45),
            ),
          ),
          SizedBox(height: media.height * 0.015),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.black,
              fontSize: media.width * 0.032,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
