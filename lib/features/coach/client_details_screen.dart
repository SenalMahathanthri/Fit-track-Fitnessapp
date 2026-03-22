import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../workout_plans/workout_controller.dart';
import '../workout_plans/widgets/add_workout_plan_dialog.dart';
import '../meal_planner/meal_plan_controller.dart';
import '../meal_planner/widgets/add_meal_plan_dialog.dart';

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel client = Get.arguments as UserModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name.isNotEmpty ? client.name : 'Client Details', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(client),
            const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Try to get the existing controller, or put a new one
                    final workoutPlanController = Get.isRegistered<WorkoutPlanController>() 
                      ? Get.find<WorkoutPlanController>() 
                      : Get.put(WorkoutPlanController());
                      
                    showDialog(
                      context: context,
                      builder: (context) => AddWorkoutPlanDialog(
                        controller: workoutPlanController,
                        assignToClientId: client.uid,
                      ),
                    );
                  },
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Assign Workout Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Assign Meal Plan Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final mealPlanController = Get.isRegistered<MealPlanController>() 
                      ? Get.find<MealPlanController>() 
                      : Get.put(MealPlanController());
                      
                    showDialog(
                      context: context,
                      builder: (context) => AddMealPlanDialog(
                        controller: mealPlanController,
                        assignToClientId: client.uid,
                      ),
                    );
                  },
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Assign Meal Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Different color for distinction
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(UserModel client) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Email', client.email),
            _buildDetailRow('Phone', client.phoneNumber.isNotEmpty ? client.phoneNumber : 'N/A'),
            _buildDetailRow('Goal', client.goalType.isNotEmpty ? client.goalType : 'N/A'),
            _buildDetailRow('Age', '${client.age} ${client.ageUnit}'),
            _buildDetailRow('Height', '${client.height} ${client.heightUnit}'),
            _buildDetailRow('Weight', '${client.weight} ${client.weightUnit}'),
            _buildDetailRow('BMI Category', client.getBMICategory()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
