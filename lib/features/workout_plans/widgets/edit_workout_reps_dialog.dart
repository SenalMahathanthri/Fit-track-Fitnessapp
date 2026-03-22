// lib/features/workout/widgets/edit_workout_reps_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/workout_model.dart';
import '../../../core/theme/app_colors.dart';

class EditWorkoutRepsDialog extends StatefulWidget {
  final Workout workout;
  final int initialSets;
  final int initialRepsPerSet;
  final Function(int sets, int repsPerSet) onSave;

  const EditWorkoutRepsDialog({
    super.key,
    required this.workout,
    required this.initialSets,
    required this.initialRepsPerSet,
    required this.onSave,
  });

  @override
  State<EditWorkoutRepsDialog> createState() => _EditWorkoutRepsDialogState();
}

class _EditWorkoutRepsDialogState extends State<EditWorkoutRepsDialog> {
  late int _sets;
  late int _repsPerSet;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets;
    _repsPerSet = widget.initialRepsPerSet;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Edit ${widget.workout.name} Details',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Sets Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sets:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    // Decrement button
                    GestureDetector(
                      onTap: () {
                        if (_sets > 1) {
                          setState(() {
                            _sets--;
                          });
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),

                    // Sets count
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$_sets',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Increment button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _sets++;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reps Per Set Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reps per set:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    // Decrement button
                    GestureDetector(
                      onTap: () {
                        if (_repsPerSet > 1) {
                          setState(() {
                            _repsPerSet--;
                          });
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),

                    // Reps count
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$_repsPerSet',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Increment button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _repsPerSet++;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),

                // Save button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_sets, _repsPerSet);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
