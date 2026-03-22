// lib/views/workouts/workouts_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/admin_custom_appbar.dart';
import '../../../data/models/workout_model.dart';
import '../../../features/dashboard/workouts/workout_controller.dart';
import 'add_workout.dart';
import 'edit_workout.dart';

class WorkoutsScreen extends StatefulWidget {
  final WorkoutType? initialFilter;
  final String? initialDifficulty;

  const WorkoutsScreen({super.key, this.initialFilter, this.initialDifficulty});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with WidgetsBindingObserver {
  WorkoutType? _selectedFilter;
  String? _selectedDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Track initial loading state
  final RxBool _isInitialLoading = true.obs;

  // Track refresh state
  final RxBool _isRefreshing = false.obs;

  late final WorkoutController workoutController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedFilter = widget.initialFilter;
    _selectedDifficulty = widget.initialDifficulty;

    // Initialize the controller
    workoutController = Get.put(WorkoutController());

    // Fetch initial data
    _fetchWorkoutsWithLoading();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  // Fetch workouts with loading state
  Future<void> _fetchWorkoutsWithLoading() async {
    _isInitialLoading.value = true;
    try {
      await workoutController.fetchWorkouts();
    } finally {
      _isInitialLoading.value = false;
    }
  }

  // Refresh data with loading state
  Future<void> _refreshData() async {
    _isRefreshing.value = true;
    try {
      await workoutController.fetchWorkouts();
    } finally {
      _isRefreshing.value = false;
    }

    // Show snackbar only if it's a manual refresh
    Get.snackbar(
      'Success',
      'Workouts refreshed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered workouts
  List<Workout> _getFilteredWorkouts() {
    return workoutController.workouts.where((workout) {
      // Apply type filter
      if (_selectedFilter != null && workout.workoutType != _selectedFilter) {
        return false;
      }

      // Apply difficulty filter
      if (_selectedDifficulty != null &&
          workout.difficulty != _selectedDifficulty) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty &&
          !workout.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: CustomAppBar(
        title: 'Workouts',
        showBackButton: true,
        actions: [
          Obx(
            () =>
                _isRefreshing.value
                    ? Container(
                      margin: const EdgeInsets.all(10),
                      width: 30,
                      height: 30,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshData,
                    ),
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
                Text('Loading workouts...'),
              ],
            ),
          );
        }

        final filteredWorkouts = _getFilteredWorkouts();

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and filter bar
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
                        hintText: 'Search workouts...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
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
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Filter types label
                    Text('Workout Type:', style: AppTextStyles.bodySmall),

                    const SizedBox(height: 8),

                    // Filter chips - Types
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'All Types',
                            _selectedFilter == null,
                            () {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                          ),
                          _buildFilterChip(
                            'Fat Burn',
                            _selectedFilter == WorkoutType.FatBurn,
                            () {
                              setState(() {
                                _selectedFilter = WorkoutType.FatBurn;
                              });
                            },
                            Colors.orange,
                          ),
                          _buildFilterChip(
                            'Weight Gain',
                            _selectedFilter == WorkoutType.WeightGain,
                            () {
                              setState(() {
                                _selectedFilter = WorkoutType.WeightGain;
                              });
                            },
                            AppColors.secondaryPurple,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter difficulty label
                    Text('Difficulty:', style: AppTextStyles.bodySmall),

                    const SizedBox(height: 8),

                    // Filter chips - Difficulties
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'All Difficulties',
                            _selectedDifficulty == null,
                            () {
                              setState(() {
                                _selectedDifficulty = null;
                              });
                            },
                          ),
                          _buildFilterChip(
                            'Easy',
                            _selectedDifficulty == 'Easy',
                            () {
                              setState(() {
                                _selectedDifficulty = 'Easy';
                              });
                            },
                            Colors.green,
                          ),
                          _buildFilterChip(
                            'Medium',
                            _selectedDifficulty == 'Medium',
                            () {
                              setState(() {
                                _selectedDifficulty = 'Medium';
                              });
                            },
                            Colors.orange,
                          ),
                          _buildFilterChip(
                            'Hard',
                            _selectedDifficulty == 'Hard',
                            () {
                              setState(() {
                                _selectedDifficulty = 'Hard';
                              });
                            },
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Workout count with loading indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${filteredWorkouts.length} Workouts',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () =>
                          workoutController.isLoading &&
                                  !_isInitialLoading.value &&
                                  !_isRefreshing.value
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

              // Workout list
              Expanded(
                child:
                    filteredWorkouts.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No workouts found',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters or add a new workout',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredWorkouts.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final workout = filteredWorkouts[index];
                            return _buildWorkoutCard(
                              context,
                              workout,
                              workoutController,
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
          ).then((_) => _refreshData());
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, [
    Color? activeColor,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color:
                isSelected
                    ? Colors.white
                    : (activeColor ?? AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: activeColor ?? AppColors.primaryBlue,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                isSelected
                    ? (activeColor ?? AppColors.primaryBlue)
                    : AppColors.textLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            onTap();
          }
        },
      ),
    );
  }

  // Modern workout card design
  Widget _buildWorkoutCard(
    BuildContext context,
    Workout workout,
    WorkoutController controller,
  ) {
    Color typeColor =
        workout.workoutType == WorkoutType.FatBurn
            ? Colors.orange
            : AppColors.secondaryPurple;

    Color difficultyColor;
    if (workout.difficulty == 'Easy') {
      difficultyColor = Colors.green;
    } else if (workout.difficulty == 'Medium') {
      difficultyColor = Colors.orange;
    } else {
      difficultyColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.name,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditWorkoutScreen(workout: workout),
                            ),
                          ).then((_) => _refreshData());
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
                            workout,
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

            const SizedBox(height: 16),

            // Workout details
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        workout.workoutType == WorkoutType.FatBurn
                            ? Icons.local_fire_department
                            : Icons.fitness_center,
                        size: 16,
                        color: typeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workout.workoutType == WorkoutType.FatBurn
                            ? 'Fat Burn'
                            : 'Weight Gain',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        workout.difficulty == 'Easy'
                            ? Icons.sentiment_satisfied
                            : workout.difficulty == 'Medium'
                            ? Icons.sentiment_neutral
                            : Icons.sentiment_very_dissatisfied,
                        size: 16,
                        color: difficultyColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workout.difficulty,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: difficultyColor,
                          fontWeight: FontWeight.bold,
                        ),
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

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Workout workout,
    WorkoutController controller,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Workout'),
            content: Text('Are you sure you want to delete "${workout.name}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await controller.deleteWorkout(workout.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${workout.name} deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete workout'),
                        backgroundColor: Colors.red,
                      ),
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
