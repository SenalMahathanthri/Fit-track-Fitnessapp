import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/workout_plan.dart';
import 'coach_controller.dart';

class PlanReviewScreen extends StatefulWidget {
  const PlanReviewScreen({super.key});

  @override
  State<PlanReviewScreen> createState() => _PlanReviewScreenState();
}

class _PlanReviewScreenState extends State<PlanReviewScreen> {
  final CoachController _controller = Get.find<CoachController>();
  final TextEditingController _commentsController = TextEditingController();
  late WorkoutPlan plan;

  @override
  void initState() {
    super.initState();
    plan = Get.arguments as WorkoutPlan;
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _controller.getClient(plan.userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Plan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            if (client != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: AppColors.primaryBlue.withOpacity(0.05),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primaryBlue),
                          const SizedBox(width: 8),
                          Text(client.name.isNotEmpty ? client.name : client.email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      Text("Goal: ${client.goalType.isNotEmpty ? client.goalType : 'General Fitness'}", style: TextStyle(color: Colors.grey[800])),
                      Text("Age: ${client.age} | Height: ${client.height} ${client.heightUnit} | Weight: ${client.weight} ${client.weightUnit}", style: TextStyle(color: Colors.grey[800])),
                      Text("BMI Category: ${client.getBMICategory()}", style: TextStyle(color: Colors.grey[800])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Plan Info Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Total Workouts: ${plan.workouts.length}", style: TextStyle(color: Colors.grey[700])),
                    Text("Estimated Calories: ${plan.estimatedCalories.toStringAsFixed(0)} cal", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 16),
                    const Text("Workouts:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...plan.workouts.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryBlue),
                          const SizedBox(width: 8),
                          Text("${w.name} (${w.durationMinutes} min)"),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Coach Comments
            const Text(
              "Coach Comments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter feedback or suggestions for this plan...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_commentsController.text.isEmpty) {
                        Get.snackbar("Error", "Please provide a reason for rejection");
                        return;
                      }
                      _controller.rejectPlan(plan.id, _commentsController.text);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _controller.approvePlan(plan.id, _commentsController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
