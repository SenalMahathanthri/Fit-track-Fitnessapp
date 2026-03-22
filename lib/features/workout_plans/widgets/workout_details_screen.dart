// lib/features/workout/workout_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/workout_plan.dart';
import '../workout_controller.dart';
import 'edit_workout_reps_dialog.dart';
import 'edit_workout_plan_screen.dart'; // Import the EditWorkoutPlanScreen

class WorkoutDetailsScreen extends StatefulWidget {
  final String workoutPlanId;

  const WorkoutDetailsScreen({super.key, required this.workoutPlanId});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final WorkoutPlanController _controller = Get.find<WorkoutPlanController>();
  late Rx<WorkoutPlan?> workoutPlan = Rx<WorkoutPlan?>(null);
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    _isLoading.value = true;
    try {
      final plan = await _controller.getWorkoutPlanById(widget.workoutPlanId);
      if (plan != null) {
        workoutPlan.value = plan;
        _controller.setSelectedWorkoutPlan(plan);
      } else {
        Get.snackbar(
          'Error',
          'Workout plan not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back(); // Navigate back if plan not found
      }
    } catch (e) {
      print('Error loading workout plan: $e');
      Get.snackbar(
        'Error',
        'Failed to load workout plan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            workoutPlan.value?.name ?? 'Workout Details',
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (workoutPlan.value == null) return const SizedBox.shrink();

            return IconButton(
              icon: Icon(
                workoutPlan.value!.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: workoutPlan.value!.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                _controller.toggleWorkoutPlanFavorite(
                  workoutPlan.value!.id,
                  !workoutPlan.value!.isFavorite,
                );
                // Update local model
                workoutPlan.value = workoutPlan.value!.copyWith(
                  isFavorite: !workoutPlan.value!.isFavorite,
                );
              },
            );
          }),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEditWorkoutPlan();
              } else if (value == 'delete') {
                _confirmDeleteWorkoutPlan(context);
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (workoutPlan.value == null) {
          return const Center(child: Text('Workout plan not found'));
        }

        return RefreshIndicator(
          onRefresh: _loadWorkoutPlan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan header and status
                  _buildPlanHeader(),
                  const SizedBox(height: 24),

                  // Workout Summary
                  _buildWorkoutSummary(),
                  const SizedBox(height: 24),

                  // Workout list
                  const Text(
                    'Workout Exercises',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Exercises list
                  _buildExercisesList(),
                  const SizedBox(height: 24),

                  // Complete/Incomplete button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _controller.toggleWorkoutPlanFinished(
                          workoutPlan.value!.id,
                          !workoutPlan.value!.isFinished,
                        );
                        // Update local model
                        workoutPlan.value = workoutPlan.value!.copyWith(
                          isFinished: !workoutPlan.value!.isFinished,
                        );
                      },
                      icon: Icon(
                        workoutPlan.value!.isFinished
                            ? Icons.close
                            : Icons.check,
                      ),
                      label: Text(
                        workoutPlan.value!.isFinished
                            ? 'Mark as Incomplete'
                            : 'Mark as Complete',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            workoutPlan.value!.isFinished
                                ? Colors.grey
                                : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Navigate to edit workout plan screen
  void _navigateToEditWorkoutPlan() {
    if (workoutPlan.value != null) {
      Get.to(
        () => EditWorkoutPlanScreen(workoutPlanId: workoutPlan.value!.id),
      )?.then((_) {
        // Refresh the workout plan data when returning from edit screen
        _loadWorkoutPlan();
      });
    }
  }

  Widget _buildPlanHeader() {
    final plan = workoutPlan.value!;
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(plan.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: plan.isFinished ? Colors.green : Colors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                plan.isFinished ? 'Completed' : 'Upcoming',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (plan.isFavorite)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Favorite',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Date and time
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plan.startTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (plan.reminder)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reminder: ${plan.reminderTime}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary() {
    final plan = workoutPlan.value!;
    final setsAndReps = plan.calculateTotalSetsAndReps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                Icons.fitness_center,
                '${plan.workouts.length}',
                'Exercises',
                AppColors.primaryBlue,
              ),
              _buildSummaryItem(
                Icons.format_list_numbered,
                '${setsAndReps['totalSets']}',
                'Sets',
                Colors.purple,
              ),
              _buildSummaryItem(
                Icons.repeat,
                '${setsAndReps['totalReps']}',
                'Reps',
                Colors.deepOrange,
              ),
              _buildSummaryItem(
                Icons.whatshot,
                '${plan.estimatedCalories.toInt()}',
                'Calories',
                Colors.orange,
              ),
              _buildSummaryItem(
                Icons.timer,
                '${plan.totalDuration}',
                'Minutes',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildExercisesList() {
    final plan = workoutPlan.value!;

    if (plan.workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'No workouts in this plan',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plan.workouts.length,
      itemBuilder: (context, index) {
        final workout = plan.workouts[index];
        final workoutReps = plan.getWorkoutReps(workout.id);
        final sets = workoutReps['sets'] as int? ?? 3;
        final repsPerSet = workoutReps['repsPerSet'] as int? ?? 10;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              workout.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${workout.durationMinutes} min • ${workout.calories.toInt()} cal',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  '$sets sets × $repsPerSet reps',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  onPressed:
                      () => _showEditWorkoutRepsDialog(
                        context,
                        workout,
                        sets,
                        repsPerSet,
                      ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              // Workout details
              if (workout.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

              // Exercise steps
              if (workout.steps.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workout.steps.length,
                      itemBuilder: (context, stepIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${stepIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  workout.steps[stepIndex],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

              // Repetition details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Repetition Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWorkoutDetailItem(
                        'Sets',
                        '$sets',
                        Icons.format_list_numbered,
                        Colors.purple,
                      ),
                      _buildWorkoutDetailItem(
                        'Reps Per Set',
                        '$repsPerSet',
                        Icons.repeat,
                        Colors.deepOrange,
                      ),
                      _buildWorkoutDetailItem(
                        'Total Reps',
                        '${sets * repsPerSet}',
                        Icons.fitness_center,
                        AppColors.primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          () => _showEditWorkoutRepsDialog(
                            context,
                            workout,
                            sets,
                            repsPerSet,
                          ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        'Edit Repetitions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showEditWorkoutPlanDialog(BuildContext context) {
    // Use the new navigation method instead
    _navigateToEditWorkoutPlan();
  }

  void _confirmDeleteWorkoutPlan(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Workout Plan"),
            content: const Text(
              "Are you sure you want to delete this workout plan? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      _controller.isDeleting.value
                          ? null
                          : () {
                            Navigator.pop(context);
                            _controller
                                .deleteWorkoutPlan(workoutPlan.value!.id)
                                .then((success) {
                                  if (success) {
                                    Get.back(); // Return to previous screen
                                  }
                                });
                          },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child:
                      _controller.isDeleting.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text("Delete"),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditWorkoutRepsDialog(
    BuildContext context,
    Workout workout,
    int currentSets,
    int currentRepsPerSet,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => EditWorkoutRepsDialog(
            workout: workout,
            initialSets: currentSets,
            initialRepsPerSet: currentRepsPerSet,
            onSave: (sets, repsPerSet) {
              // Update the workout reps in the workout plan
              final plan = workoutPlan.value!;

              // Create a copy of the existing rep data
              final updatedReps = List<Map<String, dynamic>>.from(
                plan.workoutReps,
              );

              // Find and update or add the rep data for this workout
              bool updated = false;
              for (int i = 0; i < updatedReps.length; i++) {
                if (updatedReps[i]['workoutId'] == workout.id) {
                  updatedReps[i] = {
                    'workoutId': workout.id,
                    'sets': sets,
                    'repsPerSet': repsPerSet,
                  };
                  updated = true;
                  break;
                }
              }

              if (!updated) {
                // Add new rep data if not found
                updatedReps.add({
                  'workoutId': workout.id,
                  'sets': sets,
                  'repsPerSet': repsPerSet,
                });
              }

              // Save to Firebase
              _controller.updateWorkoutReps(plan.id, updatedReps).then((
                success,
              ) {
                if (success) {
                  // Update local model
                  workoutPlan.value = plan.copyWith(workoutReps: updatedReps);
                  setState(() {}); // Rebuild the UI

                  Get.snackbar(
                    'Success',
                    'Repetitions updated successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to update repetitions',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              });
            },
          ),
    );
  }
}
