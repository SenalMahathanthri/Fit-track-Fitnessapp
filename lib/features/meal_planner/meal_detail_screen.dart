import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/meal_plan.dart';
import '../../data/models/Achievement.dart';

import '../../core/theme/app_colors.dart';
import 'meal_plan_controller.dart';
import 'widgets/meal_card.dart';
import 'widgets/add_meal_plan_dialog.dart';
import 'widgets/achievement_popup.dart';
import 'widgets/meal_details_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MealPlanController _controller = Get.put(MealPlanController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch additional data on init
    _controller.fetchUserAchievements();
    _controller.fetchUserPoints();
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
          "Meal Planner",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // User points display
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${_controller.userPoints.value} pts",
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
          // Menu button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'debug') {
                _controller.toggleDebugMode();
              } else if (value == 'achievements') {
                _showAchievementsDialog();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'debug',
                    child: Text('Toggle Debug Mode'),
                  ),
                  const PopupMenuItem(
                    value: 'achievements',
                    child: Text('View Achievements'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: "My Meals"),
            Tab(icon: Icon(Icons.today), text: "Meal Plan"),
            Tab(icon: Icon(Icons.search), text: "Food Database"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildMyMealsTab(),
              _buildMealPlanTab(),
              _buildFoodDatabaseTab(),
            ],
          ),

          // Achievement popup
          Obx(
            () =>
                _controller.showAchievementPopup.value
                    ? AchievementPopup(
                      title: _controller.achievementTitle.value,
                      description: _controller.achievementDescription.value,
                      points: _controller.achievementPoints.value,
                      onClose: _controller.hideAchievementPopup,
                    )
                    : const SizedBox.shrink(),
          ),

          // Global loading indicator
          Obx(
            () =>
                _controller.isSaving.value || _controller.isAddingMeal.value
                    ? Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealDialog(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyMealsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _controller.fetchUserMealPlans();
        await _controller.fetchUserPoints();
      },
      child: Obx(() {
        if (_controller.isLoadingUserMealPlans.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading your meal plans..."),
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
                Text('User Meal Plans: ${_controller.userMealPlans.length}'),
                Text('Today Meal Plans: ${_controller.todayMealPlans.length}'),
                Text('User Points: ${_controller.userPoints.value}'),
                Text(
                  'User Achievements: ${_controller.userAchievements.length}',
                ),
                const SizedBox(height: 4),
                const Text('User Meal Plans IDs:'),
                ..._controller.userMealPlans.map(
                  (plan) => Text('• ${plan.id} - ${plan.name} (${plan.type})'),
                ),
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
              _buildNutritionSummary(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Saved Meals",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Implement filter options
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (_controller.userMealPlans.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.userMealPlans.length,
                  itemBuilder: (context, index) {
                    final mealPlan = _controller.userMealPlans[index];
                    return MealCard(
                      mealPlan: mealPlan,
                      onDelete: () => _confirmDeleteMealPlan(mealPlan.id),
                      onToggleFavorite:
                          (isFavorite) => _controller.toggleMealPlanFavorite(
                            mealPlan.id,
                            isFavorite,
                          ),
                      onToggleCompletion:
                          (isCompleted) => _controller.toggleMealPlanCompletion(
                            mealPlan.id,
                            isCompleted,
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

  Widget _buildNutritionSummary() {
    return Obx(() {
      final dailyTotals = _controller.calculateDailyTotals();

      // Assuming these are the target values (could be made dynamic based on user settings)
      const targetCalories = 2200.0;
      const targetProteins = 120.0;
      const targetCarbs = 250.0;

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
                  "Daily Nutrition",
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
                  child: const Text(
                    "Today",
                    style: TextStyle(
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
                _buildNutrientProgress(
                  "Calories",
                  "${dailyTotals['calories']?.toInt() ?? 0}",
                  "$targetCalories",
                  (dailyTotals['calories'] ?? 0) / targetCalories,
                ),
                _buildNutrientProgress(
                  "Protein",
                  "${dailyTotals['proteins']?.toInt() ?? 0}g",
                  "${targetProteins.toInt()}g",
                  (dailyTotals['proteins'] ?? 0) / targetProteins,
                ),
                _buildNutrientProgress(
                  "Carbs",
                  "${dailyTotals['carbs']?.toInt() ?? 0}g",
                  "${targetCarbs.toInt()}g",
                  (dailyTotals['carbs'] ?? 0) / targetCarbs,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNutrientProgress(
    String label,
    String current,
    String target,
    double progress,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              current,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "/$target",
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlanTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _controller.fetchTodayMealPlans();
      },
      child: Obx(() {
        if (_controller.isLoadingTodayMealPlans.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading today's meal plans..."),
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
                  'Today\'s Meal Plans: ${_controller.todayMealPlans.length}',
                ),
                const SizedBox(height: 4),
                const Text('Today\'s Meal Plans Details:'),
                ..._controller.todayMealPlans.map(
                  (plan) => Text(
                    '• ${plan.name} (${plan.type}) - Date: ${DateFormat("yyyy-MM-dd").format(plan.date)}',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Date: ${DateFormat("yyyy-MM-dd").format(DateTime.now())}',
                ),
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
              _buildDailySummaryCard(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Meals",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _controller.fetchTodayMealPlans();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refreshing today\'s meals...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Refresh"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildMealTypeSection("Breakfast"),
              _buildMealTypeSection("Lunch"),
              _buildMealTypeSection("Dinner"),
              _buildMealTypeSection("Snack"),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDailySummaryCard() {
    return Obx(() {
      final dailyTotals = _controller.calculateDailyTotals();

      // Assuming these are the target values
      const targetCalories = 2200.0;
      const targetProteins = 120.0;
      const targetCarbs = 250.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daily Summary",
                  style: TextStyle(
                    color: AppColors.black,
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
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat("MMM d, yyyy").format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildNutrientProgressBar(
              "Calories",
              "${dailyTotals['calories']?.toInt() ?? 0}/${targetCalories.toInt()} kcal",
              (dailyTotals['calories'] ?? 0) / targetCalories,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildNutrientProgressBar(
              "Protein",
              "${dailyTotals['proteins']?.toInt() ?? 0}/${targetProteins.toInt()}g",
              (dailyTotals['proteins'] ?? 0) / targetProteins,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildNutrientProgressBar(
              "Carbs",
              "${dailyTotals['carbs']?.toInt() ?? 0}/${targetCarbs.toInt()}g",
              (dailyTotals['carbs'] ?? 0) / targetCarbs,
              AppColors.primaryBlue,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNutrientProgressBar(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress > 1.0 ? 1.0 : progress,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(String type) {
    return Obx(() {
      final meals =
          _controller.todayMealPlans
              .where(
                (mealPlan) => mealPlan.type.toLowerCase() == type.toLowerCase(),
              )
              .toList();

      // Print debug information
      if (_controller.debugMode.value) {
        print('Building meal type section for $type');
        print('Found ${meals.length} meals of type $type');
        if (meals.isNotEmpty) {
          for (var meal in meals) {
            print('Meal: ${meal.name}, type: ${meal.type}');
          }
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddMealDialog(context, initialType: type),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Debug info
          if (_controller.debugMode.value)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Found ${meals.length} ${type.toLowerCase()} meals',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

          meals.isEmpty
              ? _buildEmptyMealTypeState(type)
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final mealPlan = meals[index];
                  return Obx(
                    () =>
                        _controller.isDeleting.value &&
                                _controller.userMealPlans
                                    .where((p) => p.id == mealPlan.id)
                                    .isEmpty
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                            : GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => MealDetailsScreen(mealPlan: mealPlan),
                                );
                              },
                              child: MealCard(
                                mealPlan: mealPlan,
                                onToggleCompletion:
                                    (isCompleted) =>
                                        _controller.toggleMealPlanCompletion(
                                          mealPlan.id,
                                          isCompleted,
                                        ),
                                onDelete:
                                    () => _confirmDeleteMealPlan(mealPlan.id),
                                onToggleFavorite: (bool isFavorite) {},
                              ),
                            ),
                  );
                },
              ),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  Widget _buildEmptyMealTypeState(String type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant, color: Colors.grey.withOpacity(0.5), size: 40),
          const SizedBox(height: 10),
          Text(
            "No $type meals added yet",
            style: const TextStyle(color: AppColors.gray, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddMealDialog(context, initialType: type),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Add $type"),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDatabaseTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search for foods...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (query) => _controller.searchMeals(query),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_controller.isLoadingMeals.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.isSearching.value &&
                _controller.searchQuery.value.isEmpty) {
              return const Center(child: Text("Type to search for foods"));
            }

            final displayList =
                _controller.isSearching.value &&
                        _controller.searchQuery.value.isNotEmpty
                    ? _controller.searchResults
                    : _controller.meals;

            if (displayList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No foods found"),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final meal = displayList[index];
                return ListTile(
                  title: Text(meal.name),
                  subtitle: Text(
                    "${meal.calories.toInt()} kcal • ${meal.proteins.toInt()}g protein • ${meal.carbs.toInt()}g carbs",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed:
                        () =>
                            _showAddMealDialog(context, preselectedMeal: meal),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            color: Colors.grey.withOpacity(0.5),
            size: 70,
          ),
          const SizedBox(height: 20),
          const Text(
            "No meal plans yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add your first meal plan by tapping the + button",
            style: TextStyle(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddMealDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add Meal Plan"),
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

  void _showAddMealDialog(
    BuildContext context, {
    String? initialType,
    Meal? preselectedMeal,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AddMealPlanDialog(
            controller: _controller,
            initialType: initialType,
            // preselectedMeal: preselectedMeal,
          ),
    );
  }

  void _editMealPlan(MealPlan mealPlan) {
    // Navigate to the details screen instead of showing a simple dialog
    Get.to(() => MealDetailsScreen(mealPlan: mealPlan));
  }

  void _confirmDeleteMealPlan(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Meal Plan"),
            content: const Text(
              "Are you sure you want to delete this meal plan?",
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
                            _controller.deleteMealPlan(id);
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
                  Text(_controller.getMealPlanDebugInfo()),
                  const SizedBox(height: 16),
                  const Text("Today's Meal Plans by Type:"),
                  const SizedBox(height: 8),
                  ..._listMealPlansByType(),
                  const SizedBox(height: 16),
                  const Text("Recent Achievements:"),
                  const SizedBox(height: 8),
                  ..._listRecentAchievements(),
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

  List<Widget> _listMealPlansByType() {
    List<Widget> widgets = [];

    void addMealsByType(String type) {
      final meals =
          _controller.todayMealPlans
              .where(
                (mealPlan) => mealPlan.type.toLowerCase() == type.toLowerCase(),
              )
              .toList();

      widgets.add(
        Text(
          "$type (${meals.length}):",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      if (meals.isEmpty) {
        widgets.add(const Text("  No meals"));
      } else {
        for (var meal in meals) {
          widgets.add(Text("  • ${meal.name} (${meal.id.substring(0, 6)}...)"));
        }
      }

      widgets.add(const SizedBox(height: 8));
    }

    addMealsByType("Breakfast");
    addMealsByType("Lunch");
    addMealsByType("Dinner");
    addMealsByType("Snack");

    return widgets;
  }

  List<Widget> _listRecentAchievements() {
    List<Widget> widgets = [];

    final achievements = _controller.userAchievements;

    if (achievements.isEmpty) {
      widgets.add(const Text("  No achievements yet"));
    } else {
      // Show only the most recent 5 achievements
      final recentAchievements = achievements.take(5).toList();
      for (var achievement in recentAchievements) {
        widgets.add(
          Text(
            "  • ${achievement.title} (+${achievement.points} pts) - ${DateFormat("MMM d, yyyy").format(achievement.date)}",
            style: const TextStyle(fontSize: 12),
          ),
        );
      }
    }

    return widgets;
  }

  void _showAchievementsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Your Achievements"),
            content: SizedBox(
              width: double.maxFinite,
              child: Obx(() {
                if (_controller.isLoadingAchievements.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.userAchievements.isEmpty) {
                  return const Center(
                    child: Text(
                      "No achievements yet. Complete a meal plan to earn your first achievement!",
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _controller.userAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = _controller.userAchievements[index];
                    return ListTile(
                      leading: _getAchievementIcon(achievement as Achievement),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "+${achievement.points}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _getAchievementIcon(Achievement achievement) {
    IconData iconData;
    Color iconColor;

    // Determine icon based on achievement type
    switch (achievement.type.toString().split('.').last) {
      case 'meal':
        iconData = Icons.restaurant;
        iconColor = Colors.green;
        break;
      case 'workout':
        iconData = Icons.fitness_center;
        iconColor = Colors.orange;
        break;
      case 'water':
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case 'custom':
        // Check for specific custom types based on the achievement title
        if (achievement.title.contains('Balanced')) {
          iconData = Icons.balance;
          iconColor = Colors.purple;
        } else if (achievement.title.contains('First Meal')) {
          iconData = Icons.breakfast_dining;
          iconColor = Colors.amber;
        } else if (achievement.title.contains('Streak')) {
          iconData = Icons.local_fire_department;
          iconColor = Colors.red;
        } else {
          iconData = Icons.emoji_events;
          iconColor = Colors.amber;
        }
        break;
      default:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
}
