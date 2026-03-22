// lib/views/workouts/edit_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/admin_custom_appbar.dart';
import '../../../data/models/workout_model.dart';
import '../../../features/dashboard/workouts/workout_controller.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final workoutController = Get.put(WorkoutController());
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _durationController;
  late String _selectedDifficulty;
  late WorkoutType _selectedType;
  late List<String> _steps;
  bool _isLoading = false;

  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout.name);
    _descriptionController = TextEditingController(
      text: widget.workout.description,
    );
    _caloriesController = TextEditingController(
      text: widget.workout.calories.toString(),
    );
    _durationController = TextEditingController(
      text: widget.workout.durationMinutes.toString(),
    );
    _selectedDifficulty = widget.workout.difficulty;
    _selectedType = widget.workout.workoutType;
    _steps = List<String>.from(widget.workout.steps);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit ${widget.workout.name}',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Workout ID: ${widget.workout.id}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name field
              Text(
                'Workout Name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter workout name',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Description field
              Text(
                'Description',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter workout description',
                ),
              ),

              const SizedBox(height: 24),

              // Calories field
              Text(
                'Calories',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Estimated calories',
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Duration field
              Text(
                'Duration (minutes)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Duration in minutes',
                  prefixIcon: Icon(Icons.timer),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Difficulty selection
              Text(
                'Difficulty Level',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDifficulty,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items:
                        _difficultyLevels.map((String level) {
                          Color textColor;
                          if (level == 'Easy') {
                            textColor = Colors.green;
                          } else if (level == 'Medium') {
                            textColor = Colors.orange;
                          } else {
                            textColor = Colors.red;
                          }

                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(
                              level,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDifficulty = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Workout type selection
              Text(
                'Workout Type',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWorkoutTypeCard(
                      'Fat Burn',
                      Icons.local_fire_department,
                      Colors.orange,
                      _selectedType == WorkoutType.FatBurn,
                      () {
                        setState(() {
                          _selectedType = WorkoutType.FatBurn;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWorkoutTypeCard(
                      'Weight Gain',
                      Icons.fitness_center,
                      AppColors.secondaryPurple,
                      _selectedType == WorkoutType.WeightGain,
                      () {
                        setState(() {
                          _selectedType = WorkoutType.WeightGain;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final updatedWorkout = widget.workout.copyWith(
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                  calories: double.parse(
                                    _caloriesController.text,
                                  ),
                                  durationMinutes: int.parse(
                                    _durationController.text,
                                  ),
                                  difficulty: _selectedDifficulty,
                                  workoutType: _selectedType,
                                );

                                final success = await workoutController
                                    .updateWorkout(updatedWorkout);

                                setState(() {
                                  _isLoading = false;
                                });

                                if (success) {
                                  Get.snackbar(
                                    'Success',
                                    'Workout updated successfully',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  Get.back();
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to update workout',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                Get.snackbar(
                                  'Error',
                                  'Error: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutTypeCard(
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
