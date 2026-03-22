import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/admin_custom_appbar.dart';
import 'meal_controller.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gramsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _carbsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealController = Get.put(MealController());

    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Meal', showBackButton: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              _buildFormField(
                'Meal Name',
                _nameController,
                'Enter meal name',
                Icons.restaurant,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Nutrition information heading
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                child: Text(
                  'Nutrition Information',
                  style: AppTextStyles.heading3,
                ),
              ),

              const SizedBox(height: 16),

              // Grams field
              _buildFormField(
                'Weight (grams)',
                _gramsController,
                'Enter weight in grams',
                Icons.scale,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Calories field
              _buildFormField(
                'Calories',
                _caloriesController,
                'Enter calories',
                Icons.local_fire_department,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the calories';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Calories cannot be negative';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Proteins field
              _buildFormField(
                'Proteins (grams)',
                _proteinsController,
                'Enter protein content',
                Icons.egg_alt,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the protein content';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Protein cannot be negative';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Carbs field
              _buildFormField(
                'Carbs (grams)',
                _carbsController,
                'Enter carb content',
                Icons.grain,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the carb content';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Carbs cannot be negative';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Nutritional summary card (preview based on input)
              if (_isFormFilledForPreview()) _buildNutritionalSummary(),

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
                                final success = await mealController.addMeal(
                                  _nameController.text,
                                  double.parse(_gramsController.text),
                                  double.parse(_caloriesController.text),
                                  double.parse(_proteinsController.text),
                                  double.parse(_carbsController.text),
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meal added successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add meal'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
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
                          : const Text('Add Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
          validator: validator,
          onChanged: (_) => setState(() {}), // Refresh for the preview
        ),
      ],
    );
  }

  bool _isFormFilledForPreview() {
    return _gramsController.text.isNotEmpty &&
        double.tryParse(_gramsController.text) != null &&
        _proteinsController.text.isNotEmpty &&
        double.tryParse(_proteinsController.text) != null &&
        _carbsController.text.isNotEmpty &&
        double.tryParse(_carbsController.text) != null;
  }

  Widget _buildNutritionalSummary() {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final proteins = double.tryParse(_proteinsController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;

    final proteinPercentage = grams > 0 ? (proteins / grams) * 100 : 0;
    final carbPercentage = grams > 0 ? (carbs / grams) * 100 : 0;

    final isHighProtein = proteinPercentage > 20;
    final isLowCarb = carbPercentage < 10;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutritional Summary',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Protein percentage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Protein per 100g: ${proteinPercentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          if (isHighProtein)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'High Protein',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: proteinPercentage / 100,
                        backgroundColor: AppColors.cardBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHighProtein ? Colors.green : AppColors.primaryBlue,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Carb percentage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Carbs per 100g: ${carbPercentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          if (isLowCarb)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Low Carb',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: carbPercentage / 100,
                        backgroundColor: AppColors.cardBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLowCarb ? Colors.green : Colors.amber,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
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
