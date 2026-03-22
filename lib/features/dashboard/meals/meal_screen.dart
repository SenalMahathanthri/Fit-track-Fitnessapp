import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/admin_custom_appbar.dart';
import '../../../data/models/meal_model.dart';
import 'add_meal.dart';
import 'edit_meal_screen.dart';
import 'meal_controller.dart';

class MealsScreen extends StatefulWidget {
  final bool showHighProtein;
  final bool showLowCarb;

  const MealsScreen({
    super.key,
    this.showHighProtein = false,
    this.showLowCarb = false,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> with WidgetsBindingObserver {
  late final MealController mealController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Local state variables - not reactive (Rx)
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _ascending = true;

  // Track if initial loading has happened
  final RxBool _isInitialLoading = true.obs;

  // Cache for filtered meals
  late RxList<Meal> filteredMeals = <Meal>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controller properly
    mealController =
        Get.isRegistered<MealController>()
            ? Get.find<MealController>()
            : Get.put(MealController());

    // Initial data fetch with loading state
    _fetchMealsWithLoadingState();

    // Listen to changes in the meal list and update filtered meals
    ever(mealController.meals as RxInterface<Object?>, (_) {
      _updateFilteredMeals();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  // Fetch meals with loading state
  Future<void> _fetchMealsWithLoadingState() async {
    _isInitialLoading.value = true;
    try {
      await mealController.fetchMeals();
    } finally {
      _isInitialLoading.value = false;
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    return await mealController.fetchMeals();
  }

  // Update the filtered meals list when search, sort, or filters change
  void _updateFilteredMeals() {
    List<Meal> result = List<Meal>.from(mealController.meals);

    // Apply high protein filter
    if (widget.showHighProtein) {
      result =
          result
              .where((meal) => (meal.proteins / meal.grams) * 100 > 20)
              .toList();
    }

    // Apply low carb filter
    if (widget.showLowCarb) {
      result =
          result.where((meal) => (meal.carbs / meal.grams) * 100 < 10).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (meal) => meal.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    // Sort the meals
    result.sort((a, b) {
      int sortResult;
      switch (_sortBy) {
        case 'name':
          sortResult = a.name.compareTo(b.name);
          break;
        case 'calories':
          sortResult = a.calories.compareTo(b.calories);
          break;
        case 'proteins':
          sortResult = a.proteins.compareTo(b.proteins);
          break;
        case 'carbs':
          sortResult = a.carbs.compareTo(b.carbs);
          break;
        default:
          sortResult = a.name.compareTo(b.name);
      }
      return _ascending ? sortResult : -sortResult;
    });

    filteredMeals.value = result;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: CustomAppBar(
        title: 'Meals',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _refreshData();
              Get.snackbar(
                'Success',
                'Meals refreshed',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_isInitialLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading meals...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and sort bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search meals...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _updateFilteredMeals();
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _updateFilteredMeals();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sort options
                    Row(
                      children: [
                        Text('Sort by:', style: AppTextStyles.bodySmall),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          _buildSortChip('Name', 'name'),
                          _buildSortChip('Calories', 'calories'),
                          _buildSortChip('Protein', 'proteins'),
                          _buildSortChip('Carbs', 'carbs'),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue.withOpacity(0.1),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _ascending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 20,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ascending = !_ascending;
                                  _updateFilteredMeals();
                                });
                              },
                              tooltip: _ascending ? 'Ascending' : 'Descending',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter chips
                    if (widget.showHighProtein || widget.showLowCarb)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Text(
                              'Filters:',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            if (widget.showHighProtein)
                              _buildFilterChip('High Protein', true, () {
                                Get.off(() => const MealsScreen());
                              }),
                            if (widget.showLowCarb)
                              _buildFilterChip('Low Carb', true, () {
                                Get.off(() => const MealsScreen());
                              }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Meal count with loading indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${filteredMeals.length} Meals',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () =>
                          mealController.isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Meal list - using Obx for both loading state and filtered meals
              Expanded(
                child: Obx(() {
                  if (filteredMeals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.restaurant,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meals found',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or add a new meal',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredMeals.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final meal = filteredMeals[index];
                      return _buildModernMealCard(
                        context,
                        meal,
                        mealController,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddMealScreen())?.then((_) => _refreshData());
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _sortBy = value;
              _updateFilteredMeals();
            });
          }
        },
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textLight.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
        onDeleted: onTap,
      ),
    );
  }

  // Modern, full-width meal card that matches the screenshot design
  Widget _buildModernMealCard(
    BuildContext context,
    Meal meal,
    MealController controller,
  ) {
    // Calculate protein and carb percentages
    final proteinPercent = (meal.proteins / meal.grams) * 100;
    final carbPercent = (meal.carbs / meal.grams) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header with name and action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    // Edit button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withOpacity(0.1),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        onPressed: () {
                          Get.to(
                            () => EditMealScreen(meal: meal),
                          )?.then((_) => _refreshData());
                        },
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                            context,
                            meal,
                            controller,
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nutrition info grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModernNutrientInfo(
                  '${meal.grams.toInt()}.0g',
                  'Grams',
                  Icons.scale,
                  AppColors.textSecondary,
                ),
                _buildModernNutrientInfo(
                  '${meal.calories.toInt()}',
                  'Calories',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildModernNutrientInfo(
                  '${meal.proteins.toInt()}.0g',
                  'Proteins',
                  Icons.egg_alt,
                  AppColors.primaryBlue,
                ),
                _buildModernNutrientInfo(
                  '${meal.carbs.toInt()}.0g',
                  'Carbs',
                  Icons.grain,
                  Colors.amber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Protein progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protein per 100g: ${proteinPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: proteinPercent / 100, // Convert to 0.0-1.0 range
                    minHeight: 8,
                    backgroundColor: AppColors.cardBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      proteinPercent > 20
                          ? Colors.green
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Carbs progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carbs per 100g: ${carbPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: carbPercent / 100, // Convert to 0.0-1.0 range
                    minHeight: 8,
                    backgroundColor: AppColors.cardBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      carbPercent < 10 ? Colors.green : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNutrientInfo(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Meal meal,
    MealController controller,
  ) async {
    return Get.dialog(
      AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteMeal(meal.id);
              if (success) {
                Get.snackbar(
                  'Success',
                  '${meal.name} deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete meal',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
