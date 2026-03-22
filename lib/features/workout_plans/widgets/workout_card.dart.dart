// lib/features/workout/widgets/workout_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/workout_plan.dart';
import '../../../core/theme/app_colors.dart';
import 'package:get/get.dart';

import 'workout_details_screen.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutPlan workoutPlan;
  final Function() onDelete;
  final Function(bool isFavorite) onToggleFavorite;
  final Function(bool isFinished) onToggleFinished;

  const WorkoutCard({
    super.key,
    required this.workoutPlan,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onToggleFinished,
  });

  Color _getStatusColor(WorkoutPlan plan) {
    if (plan.status == 'pending') return Colors.orange;
    if (plan.status == 'rejected') return Colors.red;
    if (plan.isFinished) return Colors.green;
    if (plan.status == 'approved') return Colors.blue;
    return AppColors.primaryBlue;
  }

  String _getStatusText(WorkoutPlan plan) {
    if (plan.status == 'pending') return 'Pending';
    if (plan.status == 'rejected') return 'Rejected';
    if (plan.isFinished) return 'Completed';
    if (plan.status == 'approved') return 'Approved';
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, MMM d').format(workoutPlan.date);
    final setsAndReps = workoutPlan.calculateTotalSetsAndReps();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => WorkoutDetailsScreen(workoutPlanId: workoutPlan.id));
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: _getStatusColor(workoutPlan).withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color:
                            workoutPlan.isFinished
                                ? Colors.green
                                : AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: _getStatusColor(workoutPlan),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(workoutPlan),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(workoutPlan),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workoutPlan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  workoutPlan.startTime,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (workoutPlan.isFavorite) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.favorite,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Favorite',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              workoutPlan.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  workoutPlan.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                              size: 20,
                            ),
                            onPressed:
                                () => onToggleFavorite(!workoutPlan.isFavorite),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: onDelete,
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Workouts list
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exercises:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: workoutPlan.workouts.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    size: 14,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    workoutPlan.workouts[index].name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.fitness_center,
                        '${workoutPlan.workouts.length}',
                        'Exercises',
                        AppColors.primaryBlue,
                      ),
                      _buildStatItem(
                        Icons.format_list_numbered,
                        '${setsAndReps['totalSets']}',
                        'Sets',
                        Colors.purple,
                      ),
                      _buildStatItem(
                        Icons.repeat,
                        '${setsAndReps['totalReps']}',
                        'Reps',
                        Colors.deepOrange,
                      ),
                      _buildStatItem(
                        Icons.whatshot,
                        '${workoutPlan.estimatedCalories.toInt()}',
                        'Calories',
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Coach Comments
                  if (workoutPlan.coachComments != null && workoutPlan.coachComments!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: workoutPlan.status == 'rejected' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: workoutPlan.status == 'rejected' ? Colors.red : Colors.blue),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Coach note:", style: TextStyle(fontWeight: FontWeight.bold, color: workoutPlan.status == 'rejected' ? Colors.red : Colors.blue)),
                          const SizedBox(height: 4),
                          Text(workoutPlan.coachComments!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Complete button (only if approved)
                  if (workoutPlan.isApproved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => onToggleFinished(!workoutPlan.isFinished),
                        icon: Icon(
                          workoutPlan.isFinished ? Icons.close : Icons.check,
                        ),
                        label: Text(
                          workoutPlan.isFinished
                              ? 'Mark as Incomplete'
                              : 'Mark as Complete',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              workoutPlan.isFinished ? Colors.grey : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
