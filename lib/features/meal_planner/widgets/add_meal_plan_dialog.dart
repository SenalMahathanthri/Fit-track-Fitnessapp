// lib/features/meal/widgets/add_meal_plan_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/meal_model.dart';
import '../meal_plan_controller.dart';

class AddMealPlanDialog extends StatefulWidget {
  final MealPlanController controller;
  final String? initialType;
  final Meal? initialMeal;
  final String? assignToClientId; // Target user ID when Coach is creating

  const AddMealPlanDialog({
    super.key,
    required this.controller,
    this.initialType,
    this.initialMeal,
    this.assignToClientId,
  });

  @override
  State<AddMealPlanDialog> createState() => _AddMealPlanDialogState();
}

class _AddMealPlanDialogState extends State<AddMealPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  String _selectedType = 'Breakfast';
  DateTime _selectedDate = DateTime.now();
  String _startTime =
      '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';

  bool _isSaving = false;
  bool _isSearching = false;
  String _searchQuery = '';
  int _currentPage = 0;

  // Reminder settings
  bool _enableReminder = false;
  String _reminderTime = '30 minutes before';

  // List of valid reminder options - matching the ones in NotificationService
  final List<String> _reminderOptions = [
    '5 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
  ];

  // Selected meals with quantities
  final List<MealWithQuantity> _selectedMeals = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }

    if (widget.initialMeal != null) {
      _selectedMeals.add(
        MealWithQuantity(
          meal: widget.initialMeal!,
          quantity: widget.initialMeal!.grams,
        ),
      );
    }

    // Generate a default name based on type and date
    _nameController.text =
        '$_selectedType ${DateFormat('dd/MM').format(_selectedDate)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate the first page before proceeding
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentPage = 1;
        });
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        // Update the default name if it hasn't been manually changed
        if (_nameController.text ==
            '$_selectedType ${DateFormat('dd/MM').format(_selectedDate)}') {
          _nameController.text =
              '$_selectedType ${DateFormat('dd/MM').format(picked)}';
        }
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

  void _searchMeals(String query) {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    widget.controller.searchMeals(query);

    setState(() {
      _isSearching = false;
    });
  }

  void _addMeal(Meal meal) {
    // Check if meal is already selected
    if (_selectedMeals.any((item) => item.meal.id == meal.id)) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meal.name} is already in your meal plan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _selectedMeals.add(MealWithQuantity(meal: meal, quantity: meal.grams));
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${meal.name} to your meal plan'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeMeal(int index) {
    setState(() {
      _selectedMeals.removeAt(index);
    });
  }

  void _updateQuantity(int index, double quantity) {
    if (quantity <= 0) return;

    setState(() {
      _selectedMeals[index] = MealWithQuantity(
        meal: _selectedMeals[index].meal,
        quantity: quantity,
      );
    });
  }

  Future<void> _saveMealPlan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMeals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one meal'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        // Log the values being passed to addMealPlan for debugging
        debugPrint('Saving meal plan with the following details:');
        debugPrint('Name: ${_nameController.text}');
        debugPrint('Type: $_selectedType');
        debugPrint('Time: $_startTime');
        debugPrint('Date: $_selectedDate');
        debugPrint('Reminder Enabled: $_enableReminder');
        debugPrint('Reminder Time: ${_enableReminder ? _reminderTime : "N/A"}');
        debugPrint('Selected Meals: ${_selectedMeals.length}');

        for (var meal in _selectedMeals) {
          debugPrint('- ${meal.meal.name}: ${meal.quantity}g');
        }

        final bool success = await widget.controller.addMealPlan(
          name: _nameController.text,
          type: _selectedType,
          time: _startTime,
          selectedMeals: _selectedMeals.map((m) => m.meal).toList(),
          quantities: _selectedMeals.map((m) => m.quantity).toList(),
          reminder: _enableReminder,
          reminderTime: _enableReminder ? _reminderTime : '',
          date: _selectedDate,
          assignedToUserId: widget.assignToClientId,
        );

        if (success) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save meal plan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saving meal plan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentPage == 0 ? Icons.info_outline : Icons.restaurant,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentPage == 0 ? 'Meal Plan Details' : 'Select Meals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    // Step indicator
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color:
                                    _currentPage == 0
                                        ? AppColors.primaryBlue
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 2,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color:
                                    _currentPage == 1
                                        ? AppColors.primaryBlue
                                        : Colors.white,
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

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _currentPage == 0
                            ? _buildDetailsPage()
                            : _buildMealsPage(),
                  ),
                ),
              ),

              // Dialog actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage == 0
                        ? TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        )
                        : TextButton(
                          onPressed: _previousPage,
                          child: const Text('Back'),
                        ),
                    _currentPage == 0
                        ? ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Next'),
                        )
                        : ElevatedButton(
                          onPressed: _isSaving ? null : _saveMealPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Save Meal Plan'),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal Plan Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Meal Plan Name',
            hintText: 'E.g., Breakfast 12/05',
            prefixIcon: Icon(Icons.restaurant_menu),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name for your meal plan';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Meal Type
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Meal Type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          value: _selectedType,
          items:
              ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedType = newValue;

                // Update the default name if it follows the pattern
                final currentName = _nameController.text;
                final oldType = currentName.split(' ').first;
                if ([
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Snack',
                  'Other',
                ].contains(oldType)) {
                  _nameController.text = currentName.replaceFirst(
                    oldType,
                    newValue,
                  );
                }
              });
            }
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
                      style: const TextStyle(color: Colors.black, fontSize: 16),
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
                      'Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      _startTime,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Reminder option
        SwitchListTile(
          title: const Text('Set Reminder'),
          subtitle: const Text('Get notified before your meal'),
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
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Reminder Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notifications),
            ),
            value: _reminderTime,
            items:
                _reminderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _reminderTime = newValue;
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildMealsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search meals...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: _searchMeals,
        ),
        const SizedBox(height: 16),

        // Selected meals section
        if (_selectedMeals.isNotEmpty) ...[
          const Text(
            'Selected Meals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedMeals.length,
            itemBuilder: (context, index) {
              final mealWithQuantity = _selectedMeals[index];
              final meal = mealWithQuantity.meal;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(meal.calories * mealWithQuantity.quantity / meal.grams).toStringAsFixed(0)} cal • ${(meal.proteins * mealWithQuantity.quantity / meal.grams).toStringAsFixed(1)}g protein',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity selector
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed:
                                () => _updateQuantity(
                                  index,
                                  mealWithQuantity.quantity - 10,
                                ),
                          ),
                          Text(
                            '${mealWithQuantity.quantity.toInt()}g',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed:
                                () => _updateQuantity(
                                  index,
                                  mealWithQuantity.quantity + 10,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeMeal(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
        ],

        // Search results or available meals
        Obx(() {
          final meals =
              _searchQuery.isNotEmpty
                  ? widget.controller.searchResults
                  : widget.controller.meals;

          if (widget.controller.isSearching.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (meals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_food, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No meals found matching "$_searchQuery"'
                        : 'No meals available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _searchQuery.isNotEmpty ? 'Search Results' : 'Available Meals',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  final isSelected = _selectedMeals.any(
                    (item) => item.meal.id == meal.id,
                  );

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    title: Text(meal.name),
                    subtitle: Text(
                      '${meal.calories.toInt()} cal • ${meal.proteins.toStringAsFixed(1)}g protein • ${meal.carbs.toStringAsFixed(1)}g carbs',
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryBlue,
                            )
                            : IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _addMeal(meal),
                            ),
                    onTap: isSelected ? null : () => _addMeal(meal),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}

class MealWithQuantity {
  final Meal meal;
  final double quantity;

  MealWithQuantity({required this.meal, required this.quantity});
}
