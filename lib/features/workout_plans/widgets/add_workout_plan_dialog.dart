// lib/features/workout/widgets/add_workout_plan_dialog.dart
import 'package:flutter/material.dart';
import '../../../data/models/workout_model.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'edit_workout_reps_dialog.dart'; // Add this import

import '../workout_controller.dart';

class AddWorkoutPlanDialog extends StatefulWidget {
  final WorkoutPlanController controller;
  final Workout? preselectedWorkout;
  final String? assignToClientId; // Target user ID when Coach is creating

  const AddWorkoutPlanDialog({
    super.key,
    required this.controller,
    this.preselectedWorkout,
    this.assignToClientId,
  });

  @override
  State<AddWorkoutPlanDialog> createState() => _AddWorkoutPlanDialogState();
}

class _AddWorkoutPlanDialogState extends State<AddWorkoutPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<WorkoutWithReps> _selectedWorkouts = [];
  DateTime _selectedDate = DateTime.now();
  String _startTime =
      '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
  bool _enableReminder = false;
  String _reminderTime = '30 minutes before';

  // New variables for step-by-step flow
  int _currentStep = 0; // 0 = basic details, 1 = select workouts
  bool _isSearching = false;
  String _searchQuery = '';
  List<Workout> _searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedWorkout != null) {
      _selectedWorkouts.add(
        WorkoutWithReps(
          workout: widget.preselectedWorkout!,
          sets: 3,
          repsPerSet: 10,
        ),
      );

      // If preselected workout, start on the workout selection step
      _currentStep = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  // This is the updated method
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

  void _showWorkoutSelectionDialog(BuildContext context) {
    final workouts = widget.controller.getFilteredWorkouts();
    _searchResults = workouts;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Workouts'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
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
                          setState(() {
                            _searchQuery = value;
                            _isSearching = value.isNotEmpty;
                            if (_isSearching) {
                              _searchResults =
                                  workouts
                                      .where(
                                        (workout) => workout.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase()),
                                      )
                                      .toList();
                            } else {
                              _searchResults = workouts;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Workout list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final workout = _searchResults[index];
                          final isSelected = _selectedWorkouts.any(
                            (w) => w.workout.id == workout.id,
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
                                this.setState(() {
                                  if (isSelected) {
                                    _selectedWorkouts.removeWhere(
                                      (w) => w.workout.id == workout.id,
                                    );
                                  } else {
                                    _selectedWorkouts.add(
                                      WorkoutWithReps(
                                        workout: workout,
                                        sets: 3,
                                        repsPerSet: 10,
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              this.setState(() {
                                if (isSelected) {
                                  _selectedWorkouts.removeWhere(
                                    (w) => w.workout.id == workout.id,
                                  );
                                } else {
                                  _selectedWorkouts.add(
                                    WorkoutWithReps(
                                      workout: workout,
                                      sets: 3,
                                      repsPerSet: 10,
                                    ),
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

  // Custom checkbox widget to ensure correct functioning
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
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
      ),
    );
  }

  // The rest of your code remains the same...
  // ...

  // Step 1: Basic Details Screen
  Widget _buildBasicDetailsStep() {
    // Your existing implementation...
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Basic Plan Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Reminder Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notifications),
              ),
              value: _reminderTime,
              items: const [
                DropdownMenuItem(
                  value: '5 minutes before',
                  child: Text('5 minutes before'),
                ),
                DropdownMenuItem(
                  value: '15 minutes before',
                  child: Text('15 minutes before'),
                ),
                DropdownMenuItem(
                  value: '30 minutes before',
                  child: Text('30 minutes before'),
                ),
                DropdownMenuItem(
                  value: '1 hour before',
                  child: Text('1 hour before'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _reminderTime = value!;
                });
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Step 2: Select Workouts Screen
  Widget _buildSelectWorkoutsStep() {
    // Your existing implementation...
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Select Workouts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),

        // Plan name display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan Name',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d').format(_selectedDate),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Selected Workouts
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Workouts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () => _showWorkoutSelectionDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ],
        ),
        const SizedBox(height: 16),

        // Summary
        if (_selectedWorkouts.isNotEmpty)
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      '${_calculateTotalCalories()}',
                      'Calories',
                      Colors.orange,
                    ),
                    _buildSummaryItem(
                      Icons.timer,
                      '${_calculateTotalDuration()}',
                      'Minutes',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480, // Max width for the dialog
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                Row(
                  children: [
                    Expanded(
                      child: _StepIndicator(
                        step: 1,
                        title: 'Plan Details',
                        isActive: _currentStep == 0,
                        isDone: _currentStep > 0,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 1,
                      color:
                          _currentStep > 0
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _StepIndicator(
                        step: 2,
                        title: 'Add Workouts',
                        isActive: _currentStep == 1,
                        isDone: _currentStep > 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content based on current step
                _currentStep == 0
                    ? _buildBasicDetailsStep()
                    : _buildSelectWorkoutsStep(),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Back button (only on step 2)
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: const Text('Back'),
                      ),
                    const SizedBox(width: 12),

                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),

                    // Next/Save button
                    ElevatedButton(
                      onPressed:
                          _currentStep == 0 ? _goToNextStep : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(_currentStep == 0 ? 'Next' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a name for your workout plan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _currentStep++;
      });
    }
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

  int _calculateTotalCalories() {
    return _selectedWorkouts.fold(
      0,
      (sum, item) => sum + item.workout.calories.toInt(),
    );
  }

  int _calculateTotalDuration() {
    return _selectedWorkouts.fold(
      0,
      (sum, item) => sum + item.workout.durationMinutes,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedWorkouts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one workout'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Format reminder time for notification scheduling
      String formattedReminderTime = '';
      if (_enableReminder) {
        // Convert reminder time option to actual time
        int reminderMinutes = 30; // Default

        if (_reminderTime == '5 minutes before') {
          reminderMinutes = 5;
        } else if (_reminderTime == '15 minutes before') {
          reminderMinutes = 15;
        } else if (_reminderTime == '30 minutes before') {
          reminderMinutes = 30;
        } else if (_reminderTime == '1 hour before') {
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

      widget.controller
          .addWorkoutPlanWithReps(
            name: _nameController.text,
            date: _selectedDate,
            startTime: _startTime,
            selectedWorkouts: workouts,
            workoutReps: workoutReps,
            reminder: _enableReminder,
            reminderTime: formattedReminderTime,
            assignedToUserId: widget.assignToClientId,
          )
          .then((success) {
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout plan added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to add workout plan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    }
  }

  TimeOfDay _subtractMinutesFromTimeOfDay(TimeOfDay time, int minutes) {
    final totalMinutes = (time.hour * 60 + time.minute) - minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }
}

// Helper class for step indicator
class _StepIndicator extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool isDone;

  const _StepIndicator({
    required this.step,
    required this.title,
    this.isActive = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor = Colors.grey.shade300;
    if (isActive) circleColor = AppColors.primaryBlue;
    if (isDone) circleColor = Colors.green;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child:
                isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                      '$step',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color:
                isActive || isDone
                    ? AppColors.primaryBlue
                    : Colors.grey.shade600,
            fontWeight:
                isActive || isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// New model class to hold workout and reps information
class WorkoutWithReps {
  final Workout workout;
  final int sets;
  final int repsPerSet;

  WorkoutWithReps({required this.workout, this.sets = 3, this.repsPerSet = 10});
}
