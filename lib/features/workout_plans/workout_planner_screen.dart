// lib/features/workout/workout_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/workout_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/add_workout_plan_dialog.dart';
import 'widgets/achievement_popup.dart';
import 'widgets/workout_card.dart.dart';
import 'workout_controller.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkoutPlanController _controller = Get.put(WorkoutPlanController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workouts",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Goal type selector - Fixed dropdown implementation to handle empty list error
          Obx(
            () => DropdownButton<String>(
              value: _getValidGoalType(),
              underline: const SizedBox(),
              icon: const Icon(Icons.fitness_center),
              items: _buildGoalTypeItems(),
              onChanged: (value) {
                if (value != null) {
                  _controller.setUserGoalType(value);
                }
              },
            ),
          ),

          // Debug button (only visible in debug mode)
          Obx(
            () =>
                _controller.debugMode.value
                    ? IconButton(
                      icon: const Icon(Icons.bug_report),
                      onPressed: () {
                        _showDebugInfo();
                      },
                    )
                    : const SizedBox.shrink(),
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.refreshAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: "My Workouts"),
            Tab(icon: Icon(Icons.search), text: "Exercise Library"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [_buildMyWorkoutsTab(), _buildExerciseLibraryTab()],
          ),

          // Achievement popup
          Obx(
            () =>
                _controller.showAchievementPopup.value
                    ? AchievementPopup(
                      title: _controller.achievementTitle.value,
                      description: _controller.achievementDescription.value,
                      points: 10,
                      onClose: _controller.hideAchievementPopup,
                    )
                    : const SizedBox.shrink(),
          ),

          // Global loading indicator
          Obx(
            () =>
                _controller.isSaving.value || _controller.isAddingWorkout.value
                    ? Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutDialog(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Ensure goal type is valid to avoid dropdown value errors
  String _getValidGoalType() {
    final currentType = _controller.userGoalType.value;
    final validOptions = ["all", "bodygain", "weightloss"];

    // Return current value if valid, otherwise default to "all"
    return validOptions.contains(currentType) ? currentType : "all";
  }

  // Build dropdown items with proper error handling
  List<DropdownMenuItem<String>> _buildGoalTypeItems() {
    return [
      const DropdownMenuItem(value: "all", child: Text("All Workouts")),
      const DropdownMenuItem(value: "bodygain", child: Text("Body Gain")),
      const DropdownMenuItem(value: "weightloss", child: Text("Weight Loss")),
    ];
  }

  // Fixed Goal Type dropdown for Exercise Library tab
  Widget _buildGoalTypeDropdown() {
    return Obx(
      () => DropdownButton<String>(
        value: _getValidGoalType(),
        underline: const SizedBox(),
        items: _buildGoalTypeItems(),
        onChanged: (value) {
          if (value != null) {
            _controller.setUserGoalType(value);
          }
        },
      ),
    );
  }

  Widget _buildMyWorkoutsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _controller.fetchUserWorkoutPlans();
      },
      child: Obx(() {
        if (_controller.isLoadingUserWorkoutPlans.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading your workout plans..."),
              ],
            ),
          );
        }

        // Debug info
        Widget debugInfo = const SizedBox.shrink();
        if (_controller.debugMode.value) {
          debugInfo = Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Workout Plans: ${_controller.userWorkoutPlans.length}',
                ),
                Text(
                  'Today Workout Plans: ${_controller.todayWorkoutPlans.length}',
                ),
                Text('User Goal Type: ${_controller.userGoalType.value}'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              debugInfo,
              // Summary stats card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Workout Stats",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Total Plans',
                            '${_controller.totalWorkouts}',
                            Icons.fitness_center,
                            AppColors.primaryBlue,
                          ),
                          _buildStatColumn(
                            'Total Calories',
                            '${_controller.totalCalories.toInt()}',
                            Icons.whatshot,
                            Colors.orange,
                          ),
                          _buildStatColumn(
                            'Total Minutes',
                            '${_controller.totalDuration}',
                            Icons.timer,
                            Colors.green,
                          ),
                          _buildStatColumn(
                            'Points',
                            '${_controller.userPoints}',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildWorkoutSummary(),

              const SizedBox(height: 20),

              // Add workout plan button - for easier access
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddWorkoutDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Workout Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Workout Plans",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _controller.fetchUserWorkoutPlans();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // Implement filter options
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (_controller.userWorkoutPlans.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.userWorkoutPlans.length,
                  itemBuilder: (context, index) {
                    final workoutPlan = _controller.userWorkoutPlans[index];
                    return WorkoutCard(
                      workoutPlan: workoutPlan,
                      onDelete: () => _confirmDeleteWorkoutPlan(workoutPlan.id),
                      onToggleFavorite:
                          (isFavorite) => _controller.toggleWorkoutPlanFavorite(
                            workoutPlan.id,
                            isFavorite,
                          ),
                      onToggleFinished:
                          (isFinished) => _controller.toggleWorkoutPlanFinished(
                            workoutPlan.id,
                            isFinished,
                          ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary() {
    return Obx(() {
      final stats = _controller.calculateDailyWorkoutStats();
      final now = DateTime.now();
      final formattedDate = DateFormat('MMM d').format(now);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, Color(0xFF85B6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Workout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  Icons.fitness_center,
                  "${stats['completed']?.toInt() ?? 0}/${stats['total']?.toInt() ?? 0}",
                  "Workouts",
                ),
                _buildStatusItem(
                  Icons.whatshot,
                  "${stats['calories']?.toInt() ?? 0}",
                  "Calories",
                ),
                _buildStatusItem(
                  Icons.timer,
                  "${stats['duration']?.toInt() ?? 0}",
                  "Minutes",
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildExerciseLibraryTab() {
    return Column(
      children: [
        // Summary stats at the top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.fitness_center,
                      '${_controller.totalWorkouts}',
                      'Workout Plans',
                      AppColors.primaryBlue,
                    ),
                    _buildStatItem(
                      Icons.whatshot,
                      '${_controller.totalCalories.toInt()}',
                      'Total Calories',
                      Colors.orange,
                    ),
                    _buildStatItem(
                      Icons.timer,
                      '${_controller.totalDuration}',
                      'Total Minutes',
                      Colors.green,
                    ),
                    _buildStatItem(
                      Icons.emoji_events,
                      '${_controller.userPoints}',
                      'Points',
                      Colors.amber,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),

        // Goal type selector with clearer options - FIXED
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text(
                "Goal Type: ",
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Use the fixed dropdown implementation
              _buildGoalTypeDropdown(),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search exercises...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (query) => _controller.searchWorkouts(query),
          ),
        ),

        // Add Plan Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddWorkoutDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Workout Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),

        // Workout list - Expanded to fill rest of screen
        Expanded(
          child: Obx(() {
            if (_controller.isLoadingWorkouts.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get workouts based on the selected goal type - FIXED
            List<Workout> displayList = [];

            try {
              // Show workouts based on goal type with proper error handling
              if (_controller.userGoalType.value == "all") {
                // Show all workouts when "all" is selected
                displayList =
                    _controller.isSearching.value &&
                            _controller.searchQuery.value.isNotEmpty
                        ? _controller.searchResults
                        : _controller.workouts;
              } else if (_controller.userGoalType.value == "bodygain") {
                displayList =
                    _controller.isSearching.value &&
                            _controller.searchQuery.value.isNotEmpty
                        ? _controller.searchResults
                            .where(
                              (workout) =>
                                  workout.workoutType == WorkoutType.WeightGain,
                            )
                            .toList()
                        : _controller.bodyGainWorkouts;
              } else if (_controller.userGoalType.value == "weightloss") {
                displayList =
                    _controller.isSearching.value &&
                            _controller.searchQuery.value.isNotEmpty
                        ? _controller.searchResults
                            .where(
                              (workout) =>
                                  workout.workoutType == WorkoutType.FatBurn,
                            )
                            .toList()
                        : _controller.weightLossWorkouts;
              }
            } catch (e) {
              // Handle any unexpected errors
              print('Error filtering workouts: $e');
            }

            if (displayList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No exercises found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.isSearching.value
                          ? "Try a different search term"
                          : "No exercises available for ${_getGoalTypeDisplayName()}",
                      style: const TextStyle(color: AppColors.gray),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _controller.refreshAllData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Refresh Exercises"),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final workout = displayList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                workout.workoutType == WorkoutType.WeightGain
                                    ? Icons.fitness_center
                                    : Icons.directions_run,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${workout.typeDisplayName} • ${workout.difficulty}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add to Plan Button
                            ElevatedButton.icon(
                              onPressed: () {
                                _showAddWorkoutDialog(
                                  context,
                                  preselectedWorkout: workout,
                                );
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add to Plan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          workout.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWorkoutInfoChip(
                              Icons.whatshot,
                              '${workout.calories.toInt()} cal',
                              Colors.orange,
                            ),
                            _buildWorkoutInfoChip(
                              Icons.timer,
                              '${workout.durationMinutes} min',
                              Colors.green,
                            ),
                            _buildWorkoutInfoChip(
                              Icons.show_chart,
                              workout.difficulty,
                              AppColors.primaryBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showWorkoutDetails(context, workout);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // Helper method to get readable goal type name
  String _getGoalTypeDisplayName() {
    switch (_controller.userGoalType.value) {
      case "bodygain":
        return "Body Gain";
      case "weightloss":
        return "Weight Loss";
      case "all":
        return "All Workouts";
      default:
        return "All Workouts";
    }
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildWorkoutInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, Workout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              workout.workoutType == WorkoutType.FatBurn
                                  ? Icons.directions_run
                                  : Icons.fitness_center,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${workout.typeDisplayName} • ${workout.difficulty}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              Icons.whatshot,
                              '${workout.calories.toInt()}',
                              'Calories',
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              Icons.timer,
                              '${workout.durationMinutes}',
                              'Minutes',
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              Icons.show_chart,
                              workout.difficulty.toUpperCase(),
                              'Level',
                              AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        workout.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Steps
                      const Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Steps list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workout.steps.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    workout.steps[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Add to plan button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddWorkoutDialog(
                              context,
                              preselectedWorkout: workout,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add to Workout Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            color: Colors.grey.withOpacity(0.5),
            size: 70,
          ),
          const SizedBox(height: 20),
          const Text(
            "No workout plans yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add your first workout plan by tapping the + button",
            style: TextStyle(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddWorkoutDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add Workout Plan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWorkoutDialog(
    BuildContext context, {
    Workout? preselectedWorkout,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AddWorkoutPlanDialog(
            controller: _controller,
            preselectedWorkout: preselectedWorkout,
          ),
    );
  }

  void _confirmDeleteWorkoutPlan(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Workout Plan"),
            content: const Text(
              "Are you sure you want to delete this workout plan?",
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
                          ? null // Disable button when deleting
                          : () {
                            Navigator.pop(context);
                            _controller.deleteWorkoutPlan(id);
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

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Debug Information"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_controller.getWorkoutPlanDebugInfo()),
                  const SizedBox(height: 16),
                  const Text("Workout Counts by Type:"),
                  const SizedBox(height: 8),
                  Text(
                    'Body Gain Workouts: ${_controller.bodyGainWorkouts.length}',
                  ),
                  Text(
                    'Weight Loss Workouts: ${_controller.weightLossWorkouts.length}',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _controller.refreshAllData();
                  Navigator.pop(context);
                },
                child: const Text("Refresh Data"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
