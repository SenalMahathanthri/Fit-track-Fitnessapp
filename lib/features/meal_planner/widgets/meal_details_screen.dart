import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/meal_plan.dart';
import '../../../core/theme/app_colors.dart';
import '../meal_plan_controller.dart';
import 'update_meal_plan_dialog.dart';

class MealDetailsScreen extends StatelessWidget {
  final MealPlan mealPlan;
  final MealPlanController controller = Get.isRegistered<MealPlanController>()
      ? Get.find<MealPlanController>()
      : Get.put(MealPlanController());

  MealDetailsScreen({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meal Details",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showUpdateMealDialog(context),
          ),
          // Favorite button
          IconButton(
            icon: Icon(
              mealPlan.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: mealPlan.isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              controller.toggleMealPlanFavorite(
                mealPlan.id,
                !mealPlan.isFavorite,
              );
              Get.back(); // Refresh by going back
              Get.to(() => MealDetailsScreen(mealPlan: mealPlan));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealHeader(),
            const SizedBox(height: 24),
            _buildNutritionInfo(),
            const SizedBox(height: 24),
            _buildMealItems(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Show the update meal dialog
  void _showUpdateMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) =>
              UpdateMealPlanDialog(controller: controller, mealPlan: mealPlan),
    );
  }

  // Complete the meal and show achievement
  void _completeMeal(BuildContext context) {
    // First, mark all items as consumed (if not already)
    if (!mealPlan.items.every((item) => item.isConsumed)) {
      // Mark all items as consumed
      for (int i = 0; i < mealPlan.items.length; i++) {
        if (!mealPlan.items[i].isConsumed) {
          controller.markMealItemConsumed(mealPlan.id, i, true);
        }
      }
    }

    // Then complete the meal plan to trigger the achievement
    controller.toggleMealPlanCompletion(mealPlan.id, true);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Meal plan completed! Points earned."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Close the screen after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  Widget _buildMealHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF85B6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mealPlan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mealPlan.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                mealPlan.time,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          if (mealPlan.reminder) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Reminder at ${mealPlan.reminderTime}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],

          // Completion status badge
          if (mealPlan.isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrition Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientCircle(
                "Calories",
                "${mealPlan.totalCalories.toInt()}",
                Colors.orange,
              ),
              _buildNutrientCircle(
                "Protein",
                "${mealPlan.totalProteins.toInt()}g",
                Colors.green,
              ),
              _buildNutrientCircle(
                "Carbs",
                "${mealPlan.totalCarbs.toInt()}g",
                AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildMealItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Meal Items",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mealPlan.items.length,
            itemBuilder: (context, index) {
              final item = mealPlan.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Status indicator instead of checkbox
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              item.isConsumed
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          border: Border.all(
                            color: item.isConsumed ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child:
                            item.isConsumed
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 16,
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),

                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration:
                                    item.isConsumed
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    item.isConsumed
                                        ? AppColors.gray
                                        : AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.grams}g • ${item.calories.toInt()} kcal • ${item.proteins.toInt()}g protein • ${item.carbs.toInt()}g carbs",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    item.isConsumed
                                        ? AppColors.gray
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Complete meal button (only if not already completed)
        if (!mealPlan.isCompleted)
          ElevatedButton.icon(
            onPressed: () => _completeMeal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.emoji_events),
            label: const Text(
              "Complete Meal & Earn Points",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

        // Completed status message (only if already completed)
        if (mealPlan.isCompleted)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "This meal plan has been completed and points were awarded!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Keep up the good work! Complete more meals to earn achievements and points.",
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Points and achievements info (if completed)
        if (mealPlan.isCompleted)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      "You've earned points! Current total: ${controller.userPoints.value} points",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Back button
        OutlinedButton(
          onPressed: () {
            Get.back();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Back to Meal Planner"),
        ),
      ],
    );
  }
}
