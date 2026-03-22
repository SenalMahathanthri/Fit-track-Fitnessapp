import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../meal_planner/meal_detail_screen.dart';
import '../posgress_tracking/posgress_tracking_screen.dart';
import '../profile/profile_screen.dart';
import '../tracking/tracking_view.dart';
import '../workout_plans/workout_planner_screen.dart';
import 'app_bar.dart';
import 'custom_fancy_nav_bar.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentPage = 0;
  bool _showingProfileView = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const WorkoutPlannerScreen(),
      const MealPlannerScreen(),
      const ProgressTrackingScreen(),
      const TrackingView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_showingProfileView) {
      return Scaffold(
        body: const ProfileView(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () {
              setState(() {
                _showingProfileView = false;
              });
            },
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _buildAppBarTitle(),
        onNotificationTap: () {
          /* ... */
        },
        onProfileTap: () {
          setState(() {
            _showingProfileView = true;
          });
        },
        showBackButton: true,
      ),

      body: _screens[_currentPage],
      bottomNavigationBar: CustomFancyNavBar(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          CustomNavBarItem(icon: Icons.home, title: "Home"),
          CustomNavBarItem(icon: Icons.fitness_center, title: "Workout"),
          CustomNavBarItem(icon: Icons.restaurant, title: "Meal"),
          CustomNavBarItem(icon: Icons.image, title: "My Status"),
          CustomNavBarItem(icon: Icons.insert_chart, title: "Track"),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    String title = "";
    switch (_currentPage) {
      case 0:
        title = "Home";
        break;
      case 1:
        title = "Workouts";
        break;
      case 2:
        title = "Meal Plan";
        break;
      case 3:
        title = "Posgress Tracking";
        break;
      case 4:
        title = "Activity Tracking";
        break;
    }

    return Text(
      title,
      style: const TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Sample Workout View
