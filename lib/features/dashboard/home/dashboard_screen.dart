import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/admin_custom_appbar.dart';
import '../meals/meal_controller.dart';
import '../meals/meal_screen.dart';
import '../workouts/workout_controller.dart';
import '../workouts/workout_screen.dart';
import '../users/manage_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // Controllers initialization
  late final WorkoutController workoutController;
  late final MealController mealController;

  // State variables
  final RxBool _isLoading = true.obs;
  final RxBool _isRefreshing = false.obs;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // User count from Firestore
  final RxInt _userCount = 0.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers
    workoutController = Get.put(WorkoutController());
    mealController = Get.put(MealController());

    _fetchData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _fetchData() async {
    _isLoading.value = true;
    try {
      // Load data in parallel
      await Future.wait([
        workoutController.fetchWorkouts(),
        mealController.fetchMeals(),
        _fetchUserCount(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error fetching data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch user count from Firebase users collection
  Future<void> _fetchUserCount() async {
    try {
      // Get count of documents in users collection
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      _userCount.value = snapshot.size;
      print('Fetched user count: ${_userCount.value}');
    } catch (e) {
      print('Error fetching user count: $e');
      // Keep existing count if there's an error
    }
  }

  Future<void> _refreshData() async {
    _isRefreshing.value = true;
    try {
      await Future.wait([
        workoutController.fetchWorkouts(),
        mealController.fetchMeals(),
        _fetchUserCount(),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        showLogoutButton: true,
        title: 'Fitness Dashboard',
        showBackButton: false,
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
        if (_isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading dashboard...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildStatsGrid(), _buildQuickActions()],
            ),
          ),
        );
      }),
    );
  }

  // Stats grid showing key metrics
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    _userCount.value.toString(),
                    'Users',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    mealController.meals.length.toString(),
                    'Meals',
                    Icons.restaurant,
                    Colors.amber[700]!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    workoutController.workouts.length.toString(),
                    'Workouts',
                    Icons.fitness_center,
                    Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    (workoutController.workouts.length +
                            mealController.meals.length)
                        .toString(),
                    'Total Content',
                    Icons.folder,
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simple stat card
  Widget _buildStatCard(
    String count,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Quick actions section
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Manage Meals',
                  Icons.restaurant,
                  Colors.amber[700]!,
                  () => Get.to(() => const MealsScreen()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Manage Workouts',
                  Icons.fitness_center,
                  Colors.green,
                  () => Get.to(() => const WorkoutsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Manage Users',
                  Icons.people,
                  Colors.blue,
                  () => Get.to(() => const ManageUsersScreen()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: const SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  // Action button widget
  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}
