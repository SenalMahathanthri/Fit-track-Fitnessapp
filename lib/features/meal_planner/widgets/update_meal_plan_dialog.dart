import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/meal_model.dart';
import '../../../../data/models/meal_plan.dart';
import '../meal_plan_controller.dart';
import 'meal_details_screen.dart';

class UpdateMealPlanDialog extends StatefulWidget {
  final MealPlanController controller;
  final MealPlan mealPlan;

  const UpdateMealPlanDialog({
    super.key,
    required this.controller,
    required this.mealPlan,
  });

  @override
  State<UpdateMealPlanDialog> createState() => _UpdateMealPlanDialogState();
}

class _UpdateMealPlanDialogState extends State<UpdateMealPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _timeController;

  late String _selectedType;
  late List<Meal> _selectedMeals;
  late List<TextEditingController> _quantityControllers;
  late bool _enableReminder;
  late TimeOfDay _reminderTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and values with existing meal plan data
    _nameController = TextEditingController(text: widget.mealPlan.name);
    _timeController = TextEditingController(text: widget.mealPlan.time);
    _selectedType = widget.mealPlan.type;
    _selectedMeals = List.from(widget.mealPlan.items);
    _enableReminder = widget.mealPlan.reminder;
    _selectedDate = widget.mealPlan.date;

    // Parse reminder time if exists
    if (widget.mealPlan.reminderTime.isNotEmpty) {
      final timeParts = widget.mealPlan.reminderTime.split(' ');
      if (timeParts.length >= 2) {
        final timeValues = timeParts[0].split(':');
        if (timeValues.length >= 2) {
          int hour = int.tryParse(timeValues[0]) ?? 8;
          int minute = int.tryParse(timeValues[1]) ?? 0;

          // Adjust for AM/PM
          if (timeParts[1] == 'PM' && hour < 12) {
            hour += 12;
          } else if (timeParts[1] == 'AM' && hour == 12) {
            hour = 0;
          }

          _reminderTime = TimeOfDay(hour: hour, minute: minute);
        } else {
          _reminderTime = TimeOfDay.now();
        }
      } else {
        _reminderTime = TimeOfDay.now();
      }
    } else {
      _reminderTime = TimeOfDay.now();
    }

    // Initialize quantity controllers
    _quantityControllers =
        _selectedMeals
            .map((meal) => TextEditingController(text: meal.grams.toString()))
            .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMeal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select a Meal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search for meals...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (query) => widget.controller.searchMeals(query),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final displayList =
                      widget.controller.isSearching.value &&
                              widget.controller.searchQuery.value.isNotEmpty
                          ? widget.controller.searchResults
                          : widget.controller.meals;

                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final meal = displayList[index];
                      return ListTile(
                        title: Text(meal.name),
                        subtitle: Text(
                          "${meal.calories.toInt()} kcal • ${meal.proteins.toInt()}g protein",
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primaryBlue,
                          ),
                          onPressed: () {
                            setState(() {
                              // Create a copy of the meal to add to selected meals
                              final newMeal = Meal(
                                id: meal.id,
                                name: meal.name,
                                calories: meal.calories,
                                proteins: meal.proteins,
                                carbs: meal.carbs,
                                grams: meal.grams,
                                isConsumed: false,
                              );

                              _selectedMeals.add(newMeal);
                              _quantityControllers.add(
                                TextEditingController(
                                  text: meal.grams.toString(),
                                ),
                              );
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;

        // Format time for display
        final hour = picked.hour % 12 == 0 ? 12 : picked.hour % 12;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.hour < 12 ? 'AM' : 'PM';
        _timeController.text = '$hour:$minute $period';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateMealPlan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMeals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one meal item"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Prepare quantities
      List<double> quantities = [];
      for (var controller in _quantityControllers) {
        double quantity = double.tryParse(controller.text) ?? 0.0;
        if (quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Quantities must be greater than 0"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        quantities.add(quantity);
      }

      // Create updated items with correct nutritional values
      List<Meal> updatedItems = [];
      double totalCalories = 0;
      double totalProteins = 0;
      double totalCarbs = 0;

      for (int i = 0; i < _selectedMeals.length; i++) {
        final meal = _selectedMeals[i];
        final quantity = quantities[i];

        // Calculate nutrition based on original meal nutrition and new quantity
        final originalMeal = widget.controller.meals.firstWhere(
          (m) => m.id == meal.id,
          orElse: () => meal,
        );

        double itemCalories =
            originalMeal.calories * quantity / originalMeal.grams;
        double itemProteins =
            originalMeal.proteins * quantity / originalMeal.grams;
        double itemCarbs = originalMeal.carbs * quantity / originalMeal.grams;

        totalCalories += itemCalories;
        totalProteins += itemProteins;
        totalCarbs += itemCarbs;

        updatedItems.add(
          Meal(
            id: meal.id,
            name: meal.name,
            calories: itemCalories,
            proteins: itemProteins,
            carbs: itemCarbs,
            grams: quantity,
            isConsumed: meal.isConsumed,
          ),
        );
      }

      // Format reminder time
      final hour = _reminderTime.hour % 12 == 0 ? 12 : _reminderTime.hour % 12;
      final minute = _reminderTime.minute.toString().padLeft(2, '0');
      final period = _reminderTime.hour < 12 ? 'AM' : 'PM';
      final reminderTimeStr = '$hour:$minute $period';

      // Create updated meal plan
      final updatedMealPlan = MealPlan(
        id: widget.mealPlan.id,
        userId: widget.mealPlan.userId,
        name: _nameController.text,
        type: _selectedType,
        time: _timeController.text,
        items: updatedItems,
        totalCalories: totalCalories,
        totalProteins: totalProteins,
        totalCarbs: totalCarbs,
        reminder: _enableReminder,
        reminderTime: _enableReminder ? reminderTimeStr : '',
        date: _selectedDate,
        isCompleted: widget.mealPlan.isCompleted,
        isFavorite: widget.mealPlan.isFavorite,
      );

      // Update meal plan
      final success = await widget.controller.updateMealPlan(updatedMealPlan);

      if (success) {
        if (mounted) {
          Navigator.pop(context);

          // Navigate back to the details screen with the updated meal plan
          Get.off(() => MealDetailsScreen(mealPlan: updatedMealPlan));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Meal plan updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to update meal plan. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Update Meal Plan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Meal name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Meal Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a meal name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Meal type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: "Meal Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Breakfast",
                      child: Text("Breakfast"),
                    ),
                    DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                    DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                    DropdownMenuItem(value: "Snack", child: Text("Snack")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Meal time field with time picker
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: "Meal Time",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a meal time";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Meal date picker
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date: ${DateFormat('MM/dd/yyyy').format(_selectedDate)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Selected meal items section
                const Text(
                  "Meal Items",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Show selected meals
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedMeals.length,
                  itemBuilder: (context, index) {
                    final meal = _selectedMeals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        meal.isConsumed
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        meal.isConsumed
                                            ? Colors.grey
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${meal.calories.toInt()} kcal • ${meal.proteins.toInt()}g protein",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Amount (g)",
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Required";
                                }
                                if (double.tryParse(value) == null) {
                                  return "Invalid";
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedMeals.removeAt(index);
                                _quantityControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Add meal button
                ElevatedButton.icon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Meal Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Reminder switch
                SwitchListTile(
                  title: const Text("Enable Reminder"),
                  value: _enableReminder,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _enableReminder = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Save & Cancel buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gray,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateMealPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Obx(
                          () =>
                              widget.controller.isUpdating.value
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Update",
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
