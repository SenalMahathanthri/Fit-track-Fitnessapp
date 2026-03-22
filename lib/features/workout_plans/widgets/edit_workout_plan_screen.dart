// lib/features/workout/edit_workout_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/workout_plan.dart';
import '../workout_controller.dart';
import 'edit_workout_reps_dialog.dart';

class EditWorkoutPlanScreen extends StatefulWidget {
  final String workoutPlanId;

  const EditWorkoutPlanScreen({super.key, required this.workoutPlanId});

  @override
  State<EditWorkoutPlanScreen> createState() => _EditWorkoutPlanScreenState();
}

class _EditWorkoutPlanScreenState extends State<EditWorkoutPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkoutPlanController _controller = Get.find<WorkoutPlanController>();

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime =
      '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
  bool _enableReminder = false;
  // Changed to RxString to fix the dropdown error
  final RxString _reminderTime = '30 minutes before'.obs;
  final List<String> _reminderOptions = [
    '5 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
  ];

  // Workouts with reps
  List<WorkoutWithReps> _selectedWorkouts = [];

  // Loading state
  final RxBool _isLoading = true.obs;
  final RxBool _isSaving = false.obs;

  // Original workout plan data (for comparison)
  WorkoutPlan? _originalPlan;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutPlan() async {
    _isLoading.value = true;
    try {
      // Load workout plan by ID
      final plan = await _controller.getWorkoutPlanById(widget.workoutPlanId);

      if (plan != null) {
        _originalPlan = plan;

        // Set form field values
        _nameController.text = plan.name;
        _selectedDate = plan.date;
        _startTime = plan.startTime;
        _enableReminder = plan.reminder;

        // Set reminder time if it exists and is in the valid options
        if (plan.reminderTime.isNotEmpty) {
          String planReminderTime = plan.reminderTime;
          // Convert Firebase reminder time format to display format if needed
          if (!_reminderOptions.contains(planReminderTime)) {
            // If it's just a time format and not a friendly string, use default
            _reminderTime.value = '30 minutes before';
          } else {
            _reminderTime.value = planReminderTime;
          }
        } else {
          _reminderTime.value = '30 minutes before';
        }

        // Convert workouts to WorkoutWithReps
        _selectedWorkouts = [];
        for (var workout in plan.workouts) {
          final repData = plan.getWorkoutReps(workout.id);
          _selectedWorkouts.add(
            WorkoutWithReps(
              workout: workout,
              sets: repData['sets'] as int? ?? 3,
              repsPerSet: repData['repsPerSet'] as int? ?? 10,
            ),
          );
        }

        setState(() {});
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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay(
      hour: int.tryParse(_startTime.split(':')[0]) ?? TimeOfDay.now().hour,
      minute: int.tryParse(_startTime.split(':')[1]) ?? TimeOfDay.now().minute,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        _startTime =
            '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _showWorkoutSelectionDialog(BuildContext context) {
    final workouts = _controller.getFilteredWorkouts();
    final selectedWorkoutIds =
        _selectedWorkouts.map((w) => w.workout.id).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Workouts'),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search workouts...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        // Implement search filtering here if needed
                      },
                    ),
                    const SizedBox(height: 12),

                    // Workout list
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          final isSelected = selectedWorkoutIds.contains(
                            workout.id,
                          );

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.primaryBlue,
                                size: 16,
                              ),
                            ),
                            title: Text(workout.name),
                            subtitle: Text(
                              '${workout.durationMinutes} min • ${workout.calories.toInt()} cal • ${workout.difficulty}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: _buildCustomCheckbox(
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    // Remove workout
                                    this.setState(() {
                                      _selectedWorkouts.removeWhere(
                                        (w) => w.workout.id == workout.id,
                                      );
                                    });
                                  } else {
                                    // Add workout
                                    this.setState(() {
                                      _selectedWorkouts.add(
                                        WorkoutWithReps(
                                          workout: workout,
                                          sets: 3,
                                          repsPerSet: 10,
                                        ),
                                      );
                                    });
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  // Remove workout
                                  this.setState(() {
                                    _selectedWorkouts.removeWhere(
                                      (w) => w.workout.id == workout.id,
                                    );
                                  });
                                } else {
                                  // Add workout
                                  this.setState(() {
                                    _selectedWorkouts.add(
                                      WorkoutWithReps(
                                        workout: workout,
                                        sets: 3,
                                        repsPerSet: 10,
                                      ),
                                    );
                                  });
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCustomCheckbox({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
      ),
    );
  }

  void _editWorkoutReps(BuildContext context, int index) {
    final workoutWithReps = _selectedWorkouts[index];

    showDialog(
      context: context,
      builder: (context) {
        return EditWorkoutRepsDialog(
          workout: workoutWithReps.workout,
          initialSets: workoutWithReps.sets,
          initialRepsPerSet: workoutWithReps.repsPerSet,
          onSave: (sets, repsPerSet) {
            setState(() {
              _selectedWorkouts[index] = WorkoutWithReps(
                workout: workoutWithReps.workout,
                sets: sets,
                repsPerSet: repsPerSet,
              );
            });
          },
        );
      },
    );
  }

  void _saveWorkoutPlan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedWorkouts.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one workout',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _isSaving.value = true;

      try {
        // Format reminder time for notification scheduling
        String formattedReminderTime = '';
        if (_enableReminder) {
          // Convert reminder time option to actual time
          int reminderMinutes = 30; // Default

          if (_reminderTime.value == '5 minutes before') {
            reminderMinutes = 5;
          } else if (_reminderTime.value == '15 minutes before') {
            reminderMinutes = 15;
          } else if (_reminderTime.value == '30 minutes before') {
            reminderMinutes = 30;
          } else if (_reminderTime.value == '1 hour before') {
            reminderMinutes = 60;
          }

          // Calculate the reminder time based on the workout start time
          final timeParts = _startTime.split(':');
          if (timeParts.length == 2) {
            int hour = int.tryParse(timeParts[0]) ?? 0;
            int minute = int.tryParse(timeParts[1]) ?? 0;

            final workoutTime = TimeOfDay(hour: hour, minute: minute);
            final reminderTimeOfDay = _subtractMinutesFromTimeOfDay(
              workoutTime,
              reminderMinutes,
            );

            formattedReminderTime =
                '${reminderTimeOfDay.hour}:${reminderTimeOfDay.minute.toString().padLeft(2, '0')}';
          }
        }

        // Extract just the workout objects from the WorkoutWithReps objects
        final workouts = _selectedWorkouts.map((item) => item.workout).toList();

        // Store the reps information in a separate map in the workout plan
        final workoutReps =
            _selectedWorkouts
                .map(
                  (item) => {
                    'workoutId': item.workout.id,
                    'sets': item.sets,
                    'repsPerSet': item.repsPerSet,
                  },
                )
                .toList();

        // Create updated workout plan object
        final updatedPlan = WorkoutPlan(
          id: widget.workoutPlanId,
          userId: _originalPlan!.userId,
          name: _nameController.text,
          date: _selectedDate,
          startTime: _startTime,
          isFinished: _originalPlan!.isFinished,
          workouts: workouts,
          workoutReps: workoutReps,
          estimatedCalories: _calculateTotalCalories(),
          reminder: _enableReminder,
          reminderTime: _enableReminder ? _reminderTime.value : '',
          isFavorite: _originalPlan!.isFavorite,
        );

        // Save workout plan to database
        final success = await _controller.updateWorkoutPlanWithReps(
          updatedPlan,
          workoutReps,
        );

        if (success) {
          Get.back(); // Return to previous screen
          Get.snackbar(
            'Success',
            'Workout plan updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to update workout plan',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error updating workout plan: $e');
        Get.snackbar(
          'Error',
          'Failed to update workout plan: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        _isSaving.value = false;
      }
    }
  }

  double _calculateTotalCalories() {
    return _selectedWorkouts.fold(
      0,
      (sum, item) => sum + item.workout.calories,
    );
  }

  double _calculateTotalDuration() {
    return _selectedWorkouts.fold(
      0.0,
      (sum, item) => sum + item.workout.durationMinutes,
    );
  }

  TimeOfDay _subtractMinutesFromTimeOfDay(TimeOfDay time, int minutes) {
    final totalMinutes = (time.hour * 60 + time.minute) - minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Workout Plan',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () =>
                _isSaving.value
                    ? Container(
                      margin: const EdgeInsets.all(10),
                      width: 30,
                      height: 30,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: const Icon(
                        Icons.save,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: _saveWorkoutPlan,
                    ),
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                const Text(
                  'Basic Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),

                // Workout Plan Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Workout Plan Name',
                    hintText: 'E.g., Morning Workout',
                    prefixIcon: Icon(Icons.fitness_center),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for your workout plan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Selection
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEEE, MMM d, yyyy',
                              ).format(_selectedDate),
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Selection
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _startTime,
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reminder option
                SwitchListTile(
                  title: const Text('Set Reminder'),
                  subtitle: const Text('Get notified before your workout'),
                  value: _enableReminder,
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _enableReminder = value;
                    });
                  },
                ),

                // Reminder time selection (visible only if reminder is enabled)
                if (_enableReminder)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Reminder Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notifications),
                        ),
                        value: _reminderTime.value,
                        items:
                            _reminderOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            _reminderTime.value = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Section title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workouts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showWorkoutSelectionDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Workout'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Workouts
                if (_selectedWorkouts.isEmpty)
                  Container(
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
                          'No workouts selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedWorkouts.length,
                    itemBuilder: (context, index) {
                      final workoutWithReps = _selectedWorkouts[index];
                      final workout = workoutWithReps.workout;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${workout.durationMinutes} min • ${workout.calories.toInt()} cal',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedWorkouts.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Repetition information
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${workoutWithReps.sets} sets × ${workoutWithReps.repsPerSet} reps',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed:
                                        () => _editWorkoutReps(context, index),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Summary
                if (_selectedWorkouts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Workout Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              Icons.fitness_center,
                              '${_selectedWorkouts.length}',
                              'Exercises',
                              AppColors.primaryBlue,
                            ),
                            _buildSummaryItem(
                              Icons.whatshot,
                              '${_calculateTotalCalories().toInt()}',
                              'Calories',
                              Colors.orange,
                            ),
                            _buildSummaryItem(
                              Icons.timer,
                              '${_calculateTotalDuration().toInt()}',
                              'Minutes',
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveWorkoutPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Obx(
                      () =>
                          _isSaving.value
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class WorkoutWithReps {
  final Workout workout;
  final int sets;
  final int repsPerSet;

  WorkoutWithReps({required this.workout, this.sets = 3, this.repsPerSet = 10});
}
