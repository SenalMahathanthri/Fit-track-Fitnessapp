import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';

class TrackingView extends StatefulWidget {
  const TrackingView({super.key});

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Water tracking data
  List<Map<String, dynamic>> waterIntakes = [
    {"time": "7:30 AM", "amount": 500, "label": "Morning Start"},
    {"time": "10:15 AM", "amount": 500, "label": "Mid-Morning"},
    {"time": "1:30 PM", "amount": 750, "label": "Lunch"},
    {"time": "4:45 PM", "amount": 750, "label": "Afternoon"},
  ];
  double totalWaterIntake = 2.5; // in liters
  double waterTarget = 4.0; // in liters

  // Sleep tracking data
  Map<String, dynamic> sleepData = {
    "bedtime": "11:30 PM",
    "wakeTime": "6:50 AM",
    "deepSleep": 195, // in minutes
    "lightSleep": 245, // in minutes
    "remSleep": 90, // in minutes
    "qualityScore": 85,
  };

  // Calorie tracking data
  List<Map<String, dynamic>> mealCalories = [
    {
      "meal": "Breakfast",
      "calories": 420,
      "time": "7:30 AM",
      "icon": Icons.free_breakfast,
    },
    {
      "meal": "Morning Snack",
      "calories": 150,
      "time": "10:30 AM",
      "icon": Icons.apple,
    },
    {
      "meal": "Lunch",
      "calories": 650,
      "time": "1:00 PM",
      "icon": Icons.lunch_dining,
    },
    {
      "meal": "Afternoon Snack",
      "calories": 120,
      "time": "4:00 PM",
      "icon": Icons.cookie,
    },
    {
      "meal": "Dinner",
      "calories": 580,
      "time": "7:30 PM",
      "icon": Icons.dinner_dining,
    },
  ];

  List<Map<String, dynamic>> exerciseCalories = [
    {
      "activity": "Morning Run",
      "calories": 320,
      "time": "6:30 AM",
      "duration": "30 min",
      "icon": Icons.directions_run,
    },
    {
      "activity": "Weight Training",
      "calories": 280,
      "time": "5:45 PM",
      "duration": "45 min",
      "icon": Icons.fitness_center,
    },
  ];

  // Weight tracking data
  List<Map<String, dynamic>> weightHistory = [
    {"date": DateTime.now(), "weight": 70.5},
    {"date": DateTime.now().subtract(const Duration(days: 7)), "weight": 71.2},
    {"date": DateTime.now().subtract(const Duration(days: 14)), "weight": 72.0},
    {"date": DateTime.now().subtract(const Duration(days: 30)), "weight": 73.5},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Activity Tracking",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: "Overview"),
            Tab(icon: Icon(Icons.water_drop_outlined), text: "Water"),
            Tab(icon: Icon(Icons.bedtime_outlined), text: "Sleep"),
            Tab(
              icon: Icon(Icons.local_fire_department_outlined),
              text: "Calories",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(media),
          _buildWaterTrackingTab(media),
          _buildSleepTrackingTab(media),
          _buildCalorieTrackingTab(media),
        ],
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Different FAB for each tab
    switch (_tabController.index) {
      case 1: // Water tab
        return FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          onPressed: () => _showAddWaterIntakeDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Sleep tab
        return FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          onPressed: () => _showSetSleepScheduleDialog(),
          child: const Icon(Icons.alarm_add, color: Colors.white),
        );
      case 3: // Calories tab
        return FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          onPressed: () => _showAddCaloriesDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
  }

  Widget _buildOverviewTab(Size media) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(media.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrackingStats(media),
          SizedBox(height: media.height * 0.02),
          _buildWeightTrackingCard(media),
          SizedBox(height: media.height * 0.02),
          _buildGoalsProgressCard(media),
        ],
      ),
    );
  }

  Widget _buildTrackingStats(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Activity",
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Apr 11, 2025",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                "Steps",
                "6,500",
                "10,000",
                Icons.directions_walk,
                0.65,
              ),
              _buildOverviewItem(
                "Calories",
                "760",
                "2,200",
                Icons.local_fire_department,
                0.35,
              ),
              _buildOverviewItem(
                "Water",
                "${totalWaterIntake}L",
                "${waterTarget}L",
                Icons.water_drop,
                totalWaterIntake / waterTarget,
              ),
              _buildOverviewItem(
                "Sleep",
                "${_calculateTotalSleepHours()}h",
                "8h",
                Icons.bedtime,
                _calculateTotalSleepHours() / 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
    String title,
    String value,
    String target,
    IconData icon,
    double progress,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Goal: $target",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTrackingCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.monitor_weight,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Weight Tracking",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "${weightHistory.first['weight']} kg",
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.02),
          SizedBox(height: media.height * 0.15, child: _buildWeightChart()),
          SizedBox(height: media.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightTrendItem(
                "1 Month",
                "${weightHistory.last['weight']} kg",
                "↓ -3.0 kg",
                AppColors.primaryBlue,
              ),
              _buildWeightTrendItem(
                "1 Week",
                "${weightHistory[1]['weight']} kg",
                "↓ -0.7 kg",
                AppColors.primaryBlue,
              ),
              _buildWeightTrendItem(
                "Goal",
                "68.0 kg",
                "→ 2.5 kg left",
                AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrendItem(
    String period,
    String weight,
    String change,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period,
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          weight,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          change,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart() {
    // Sort the weight history by date (oldest to newest)
    final sortedData = List<Map<String, dynamic>>.from(
      weightHistory,
    )..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              sortedData.length,
              (index) => FlSpot(index.toDouble(), sortedData[index]['weight']),
            ),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.primaryLightBlue, AppColors.primaryBlue],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLightBlue.withOpacity(0.3),
                  AppColors.primaryBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minY:
            sortedData
                .map((e) => e['weight'] as double)
                .reduce((a, b) => a < b ? a : b) -
            1,
        maxY:
            sortedData
                .map((e) => e['weight'] as double)
                .reduce((a, b) => a > b ? a : b) +
            1,
      ),
    );
  }

  Widget _buildGoalsProgressCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Goals",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: media.height * 0.015),
          _buildGoalProgressItem(
            "Exercise 5 times a week",
            "3/5 completed",
            0.6,
            AppColors.primaryBlue,
          ),
          SizedBox(height: media.height * 0.015),
          _buildGoalProgressItem(
            "Drink 28L of water weekly",
            "16.5/28L completed",
            0.59,
            AppColors.primaryLightBlue,
          ),
          SizedBox(height: media.height * 0.015),
          _buildGoalProgressItem(
            "Sleep 8 hours daily",
            "4/7 days completed",
            0.57,
            AppColors.primaryBlue,
          ),
          SizedBox(height: media.height * 0.015),
          _buildGoalProgressItem(
            "Maintain calorie deficit",
            "5/7 days completed",
            0.71,
            AppColors.primaryLightBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressItem(
    String title,
    String progress,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              progress,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }

  // WATER TRACKING TAB
  Widget _buildWaterTrackingTab(Size media) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(media.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaterOverviewCard(media),
          SizedBox(height: media.height * 0.02),
          _buildWaterIntakesTimeline(media),
          SizedBox(height: media.height * 0.02),
          _buildWaterGoalsCard(media),
        ],
      ),
    );
  }

  Widget _buildWaterOverviewCard(Size media) {
    final double progress = totalWaterIntake / waterTarget;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLightBlue, AppColors.primaryBlue],
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
                "Today's Water Intake",
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${totalWaterIntake}L / ${waterTarget}L",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.03),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "You need to drink ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text:
                                "${(waterTarget - totalWaterIntake).toStringAsFixed(1)}L more",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: " to reach your goal",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: media.width * 0.04),
              Container(
                height: 100,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _quickAddWater(250),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text(
                      "250ml",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntakesTimeline(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Water Intakes",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showAddWaterIntakeDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Add",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: waterIntakes.length,
            itemBuilder: (context, index) {
              final intake = waterIntakes[index];
              return _buildWaterTimelineItem(
                intake["time"],
                intake["amount"],
                intake["label"],
                index,
                media,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTimelineItem(
    String time,
    int amount,
    String label,
    int index,
    Size media,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time indicator
        SizedBox(
          width: 60,
          child: Text(
            time,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Timeline connector
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue, width: 3),
              ),
            ),
            if (index < waterIntakes.length - 1)
              Container(
                width: 2,
                height: 60,
                color: AppColors.primaryLightBlue.withOpacity(0.2),
              ),
          ],
        ),

        SizedBox(width: media.width * 0.03),

        // Intake details
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryLightBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$amount ml",
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => _editWaterIntake(index),
                      child: const Icon(
                        Icons.edit,
                        color: AppColors.gray,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterGoalsCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Water Schedule",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: media.height * 0.015),
          _buildWaterScheduleItem(
            "7:00 AM",
            "First glass after waking up",
            true,
            media,
          ),
          _buildWaterScheduleItem(
            "9:00 AM",
            "Mid-morning hydration",
            true,
            media,
          ),
          _buildWaterScheduleItem("12:00 PM", "Before lunch", true, media),
          _buildWaterScheduleItem(
            "3:00 PM",
            "Afternoon refreshment",
            false,
            media,
          ),
          _buildWaterScheduleItem("6:00 PM", "Evening hydration", false, media),
          _buildWaterScheduleItem("9:00 PM", "Before bed", false, media),
          SizedBox(height: media.height * 0.015),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showWaterScheduleDialog(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("Edit Water Schedule"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterScheduleItem(
    String time,
    String label,
    bool completed,
    Size media,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  completed
                      ? AppColors.primaryBlue.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.water_drop_outlined,
              color: completed ? AppColors.primaryBlue : Colors.grey,
              size: 16,
            ),
          ),
          SizedBox(width: media.width * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.gray, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Switch(
            value: completed,
            onChanged: (value) {
              // In a real app, update the completed status
            },
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  // SLEEP TRACKING TAB
  Widget _buildSleepTrackingTab(Size media) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(media.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSleepOverviewCard(media),
          SizedBox(height: media.height * 0.02),
          _buildSleepQualityCard(media),
          SizedBox(height: media.height * 0.02),
          _buildSleepScheduleCard(media),
        ],
      ),
    );
  }

  Widget _buildSleepOverviewCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Last Night's Sleep",
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "7h 20m",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSleepTimeItem(
                "${sleepData['bedtime']}",
                "Bedtime",
                Icons.nightlight,
                media,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  Container(
                    width: media.width * 0.2,
                    height: 2,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
              _buildSleepTimeItem(
                "${sleepData['wakeTime']}",
                "Wake Up",
                Icons.wb_sunny,
                media,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepPhaseItem(
                "Deep Sleep",
                "${(sleepData['deepSleep'] / 60).toStringAsFixed(1)}h",
                const Color(0xFF0D47A1),
                media,
              ),
              _buildSleepPhaseItem(
                "Light Sleep",
                "${(sleepData['lightSleep'] / 60).toStringAsFixed(1)}h",
                const Color(0xFF1976D2),
                media,
              ),
              _buildSleepPhaseItem(
                "REM",
                "${(sleepData['remSleep'] / 60).toStringAsFixed(1)}h",
                const Color(0xFF42A5F5),
                media,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTimeItem(
    String time,
    String label,
    IconData icon,
    Size media,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSleepPhaseItem(
    String phase,
    String duration,
    Color color,
    Size media,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              duration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          phase,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSleepQualityCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_graph,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Sleep Quality",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "GOOD",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.02),
          SizedBox(
            height: media.height * 0.15,
            child: _buildSleepQualityChart(media),
          ),
          SizedBox(height: media.height * 0.02),
          const Text(
            "Insights",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSleepInsightItem(
            "Your deep sleep duration was higher than usual, which is excellent for recovery.",
            Icons.thumb_up,
            AppColors.primaryBlue,
          ),
          _buildSleepInsightItem(
            "You went to bed 30 minutes later than your ideal bedtime.",
            Icons.info,
            AppColors.primaryLightBlue,
          ),
          _buildSleepInsightItem(
            "Try to maintain a consistent wake-up time for better sleep rhythm.",
            Icons.lightbulb,
            AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityChart(Size media) {
    // For simplicity, we'll create a dummy sleep quality chart
    // In a real app, this would be a more complex chart showing sleep stages
    return Row(
      children: [
        // Y-axis labels
        const Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Awake",
              style: TextStyle(color: AppColors.gray, fontSize: 10),
            ),
            Text("REM", style: TextStyle(color: AppColors.gray, fontSize: 10)),
            Text(
              "Light",
              style: TextStyle(color: AppColors.gray, fontSize: 10),
            ),
            Text("Deep", style: TextStyle(color: AppColors.gray, fontSize: 10)),
          ],
        ),
        const SizedBox(width: 8),
        // Chart area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                10,
                (index) => _buildSleepQualityBar(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepQualityBar(int index) {
    // Generate a random sleep quality bar for visualization
    final random = DateTime.now().millisecondsSinceEpoch + index;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: 8 + (random % 8).toDouble(), // Deep sleep
          color: const Color(0xFF0D47A1),
        ),
        Container(
          width: 14,
          height: 10 + (random % 12).toDouble(), // Light sleep
          color: const Color(0xFF1976D2),
        ),
        Container(
          width: 14,
          height: 6 + (random % 10).toDouble(), // REM
          color: const Color(0xFF42A5F5),
        ),
        Container(
          width: 14,
          height: 2 + (random % 4).toDouble(), // Awake
          color: Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildSleepInsightItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScheduleCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sleep Schedule",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showSetSleepScheduleDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Edit",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSleepScheduleTimeItem(
            "Bedtime",
            "11:30 PM",
            "Reminder at 11:00 PM",
            Icons.nightlight,
            AppColors.primaryBlue,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, height: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "8h 00m",
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, height: 1),
                ),
              ],
            ),
          ),
          _buildSleepScheduleTimeItem(
            "Wake Up",
            "7:30 AM",
            "Gentle alarm with increasing volume",
            Icons.wb_sunny,
            AppColors.primaryLightBlue,
          ),
          const SizedBox(height: 16),
          const Text(
            "Sleep Reminders",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildSleepReminderItem("Stop screen time", "10:30 PM", true),
          _buildSleepReminderItem("Relax with meditation", "11:00 PM", true),
          _buildSleepReminderItem("Prepare bedroom", "11:15 PM", false),
        ],
      ),
    );
  }

  Widget _buildSleepScheduleTimeItem(
    String label,
    String time,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
            Text(
              time,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepReminderItem(String reminder, String time, bool isOn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder,
                  style: const TextStyle(color: AppColors.black, fontSize: 14),
                ),
                Text(
                  time,
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: (value) {
              // In a real app, update the reminder status
            },
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  // CALORIE TRACKING TAB
  Widget _buildCalorieTrackingTab(Size media) {
    int consumedCalories = mealCalories.fold(
      0,
      (sum, meal) => sum + (meal["calories"] as int),
    );
    int burnedCalories = exerciseCalories.fold(
      0,
      (sum, exercise) => sum + (exercise["calories"] as int),
    );
    int netCalories = consumedCalories - burnedCalories;
    int calorieGoal = 2200;
    int remainingCalories = calorieGoal - netCalories;

    return SingleChildScrollView(
      padding: EdgeInsets.all(media.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieOverviewCard(
            consumedCalories,
            burnedCalories,
            netCalories,
            calorieGoal,
            remainingCalories,
            media,
          ),
          SizedBox(height: media.height * 0.02),
          _buildMealTrackingCard(media),
          SizedBox(height: media.height * 0.02),
          _buildExerciseTrackingCard(media),
          SizedBox(height: media.height * 0.02),
          _buildNutritionBreakdownCard(media),
        ],
      ),
    );
  }

  Widget _buildCalorieOverviewCard(
    int consumed,
    int burned,
    int net,
    int goal,
    int remaining,
    Size media,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLightBlue, AppColors.primaryBlue],
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
                "Calorie Summary",
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Today",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalorieCircle("Consumed", consumed, Colors.white, media),
              SizedBox(width: media.width * 0.06),
              _buildCalorieCircle(
                "Burned",
                burned,
                const Color(0xFF42A5F5),
                media,
              ),
              SizedBox(width: media.width * 0.06),
              _buildCalorieCircle("Net", net, Colors.white, media),
            ],
          ),
          SizedBox(height: media.height * 0.03),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Remaining Calories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$remaining kcal",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: media.height * 0.015),
          LinearProgressIndicator(
            value: 1 - (remaining / goal),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          SizedBox(height: media.height * 0.01),
          Text(
            "Goal: $goal kcal",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCircle(String label, int value, Color color, Size media) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMealTrackingCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Meals",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAddMealDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Add Meal",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mealCalories.length,
            itemBuilder: (context, index) {
              final meal = mealCalories[index];
              return _buildMealItem(
                meal["meal"],
                meal["calories"],
                meal["time"],
                meal["icon"],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(String meal, int calories, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "$calories kcal",
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTrackingCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primaryLightBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Exercise",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAddExerciseDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: AppColors.primaryLightBlue,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Add Exercise",
                      style: TextStyle(
                        color: AppColors.primaryLightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          exerciseCalories.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_run,
                        color: AppColors.gray.withOpacity(0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "No exercises recorded today",
                        style: TextStyle(color: AppColors.gray, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddExerciseDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Add Exercise"),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exerciseCalories.length,
                itemBuilder: (context, index) {
                  final exercise = exerciseCalories[index];
                  return _buildExerciseItem(
                    exercise["activity"],
                    exercise["calories"],
                    exercise["time"],
                    exercise["duration"],
                    exercise["icon"],
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(
    String activity,
    int calories,
    String time,
    String duration,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryLightBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$time · $duration",
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "-$calories kcal",
            style: const TextStyle(
              color: AppColors.primaryLightBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBreakdownCard(Size media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Nutrition Breakdown",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.02),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(height: 150, child: _buildNutritionPieChart()),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildNutrientItem(
                      "Carbs",
                      "187g",
                      "250g",
                      0.75,
                      const Color(0xFF42A5F5),
                    ),
                    const SizedBox(height: 16),
                    _buildNutrientItem(
                      "Protein",
                      "96g",
                      "120g",
                      0.8,
                      const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 16),
                    _buildNutrientItem(
                      "Fat",
                      "47g",
                      "70g",
                      0.67,
                      const Color(0xFF0D47A1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: media.height * 0.02),
          const Text(
            "Micronutrients",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMicronutrientItem(
                  "Vitamin C",
                  "85%",
                  0.85,
                  const Color(0xFF42A5F5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMicronutrientItem(
                  "Calcium",
                  "63%",
                  0.63,
                  const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMicronutrientItem(
                  "Iron",
                  "72%",
                  0.72,
                  const Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMicronutrientItem(
                  "Fiber",
                  "54%",
                  0.54,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPieChart() {
    // Placeholder for a pie chart - in a real app, use a proper charting library
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(150, 150),
        painter: PieChartPainter(),
      ),
    );
  }

  Widget _buildNutrientItem(
    String nutrient,
    String current,
    String goal,
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
              nutrient,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: current,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "/$goal",
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMicronutrientItem(
    String nutrient,
    String percentage,
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
              nutrient,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
      ],
    );
  }

  // HELPER METHODS
  double _calculateTotalSleepHours() {
    final deepSleepHours = sleepData["deepSleep"] / 60;
    final lightSleepHours = sleepData["lightSleep"] / 60;
    final remSleepHours = sleepData["remSleep"] / 60;
    double hours = deepSleepHours + lightSleepHours + remSleepHours;
    return hours.roundToDouble();
  }

  // DIALOG FUNCTIONS
  void _showAddWaterIntakeDialog() {
    int amount = 250;
    String label = "Quick Drink";
    TimeOfDay time = TimeOfDay.now();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Water Intake"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Amount:"),
                          Text(
                            "$amount ml",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: amount.toDouble(),
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        label: "$amount ml",
                        activeColor: AppColors.primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            amount = value.round();
                          });
                        },
                      ),

                      // Time picker field
                      ListTile(
                        title: const Text("Time"),
                        subtitle: Text(
                          "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setState(() {
                              time = picked;
                            });
                          }
                        },
                      ),

                      // Label text field
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Label",
                          hintText: "E.g., Morning Hydration",
                        ),
                        onChanged: (value) {
                          label = value;
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add new water intake
                        setState(() {
                          // Format time
                          final hour = time.hourOfPeriod;
                          final minute = time.minute.toString().padLeft(2, '0');
                          final period =
                              time.period == DayPeriod.am ? 'AM' : 'PM';

                          waterIntakes.add({
                            "time": "$hour:$minute $period",
                            "amount": amount,
                            "label": label.isEmpty ? "Quick Drink" : label,
                          });

                          // Update total water intake
                          totalWaterIntake += amount / 1000;
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _quickAddWater(int amount) {
    setState(() {
      final now = TimeOfDay.now();
      final hour = now.hourOfPeriod;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.period == DayPeriod.am ? 'AM' : 'PM';

      waterIntakes.add({
        "time": "$hour:$minute $period",
        "amount": amount,
        "label": "Quick Drink",
      });

      totalWaterIntake += amount / 1000;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added $amount ml of water"),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editWaterIntake(int index) {
    int amount = waterIntakes[index]["amount"];
    String label = waterIntakes[index]["label"];
    String timeStr = waterIntakes[index]["time"];

    // Parse time string (e.g., "7:30 AM")
    final timeParts = timeStr.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    if (timeParts[1] == 'PM' && hour < 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;

    TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Edit Water Intake"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Amount:"),
                          Text(
                            "$amount ml",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: amount.toDouble(),
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        label: "$amount ml",
                        activeColor: AppColors.primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            amount = value.round();
                          });
                        },
                      ),

                      // Time picker field
                      ListTile(
                        title: const Text("Time"),
                        subtitle: Text(
                          "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setState(() {
                              time = picked;
                            });
                          }
                        },
                      ),

                      // Label text field
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Label",
                          hintText: "E.g., Morning Hydration",
                        ),
                        controller: TextEditingController(text: label),
                        onChanged: (value) {
                          label = value;
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Update water intake
                        setState(() {
                          // Subtract old amount from total
                          totalWaterIntake -=
                              waterIntakes[index]["amount"] / 1000;

                          // Format time
                          final hour = time.hourOfPeriod;
                          final minute = time.minute.toString().padLeft(2, '0');
                          final period =
                              time.period == DayPeriod.am ? 'AM' : 'PM';

                          // Update intake
                          waterIntakes[index] = {
                            "time": "$hour:$minute $period",
                            "amount": amount,
                            "label": label.isEmpty ? "Quick Drink" : label,
                          };

                          // Add new amount to total
                          totalWaterIntake += amount / 1000;
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          totalWaterIntake -=
                              waterIntakes[index]["amount"] / 1000;
                          waterIntakes.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showWaterScheduleDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Water Schedule"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Set up reminders to drink water throughout the day",
                    style: TextStyle(fontSize: 14, color: AppColors.gray),
                  ),
                  const SizedBox(height: 16),
                  _buildWaterScheduleDialogItem("7:00 AM", true),
                  _buildWaterScheduleDialogItem("9:00 AM", true),
                  _buildWaterScheduleDialogItem("12:00 PM", true),
                  _buildWaterScheduleDialogItem("3:00 PM", false),
                  _buildWaterScheduleDialogItem("6:00 PM", false),
                  _buildWaterScheduleDialogItem("9:00 PM", false),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add new water schedule time
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Time"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Save water schedule
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Water schedule updated"),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildWaterScheduleDialogItem(String time, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              // Update enabled state
            },
            activeColor: AppColors.primaryBlue,
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              // Edit time
            },
          ),
        ],
      ),
    );
  }

  void _showSetSleepScheduleDialog() {
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 30);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 50);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Set Sleep Schedule"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Set your ideal sleep and wake times",
                        style: TextStyle(fontSize: 14, color: AppColors.gray),
                      ),
                      const SizedBox(height: 16),

                      // Bedtime picker
                      ListTile(
                        leading: const Icon(
                          Icons.nightlight,
                          color: AppColors.primaryBlue,
                        ),
                        title: const Text("Bedtime"),
                        subtitle: Text(
                          "${bedtime.hour}:${bedtime.minute.toString().padLeft(2, '0')} ${bedtime.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: bedtime,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryBlue,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              bedtime = picked;
                            });
                          }
                        },
                      ),

                      // Wake time picker
                      ListTile(
                        leading: const Icon(
                          Icons.wb_sunny,
                          color: AppColors.primaryLightBlue,
                        ),
                        title: const Text("Wake Up"),
                        subtitle: Text(
                          "${wakeTime.hour}:${wakeTime.minute.toString().padLeft(2, '0')} ${wakeTime.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: wakeTime,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryLightBlue,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              wakeTime = picked;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Set reminder options
                      const Text(
                        "Reminders",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      CheckboxListTile(
                        title: const Text(
                          "Remind me 30 minutes before bedtime",
                        ),
                        value: true,
                        onChanged: (value) {
                          // Update reminder setting
                        },
                        activeColor: AppColors.primaryBlue,
                        contentPadding: EdgeInsets.zero,
                      ),

                      CheckboxListTile(
                        title: const Text(
                          "Gentle wake-up alarm (gradually increasing volume)",
                        ),
                        value: true,
                        onChanged: (value) {
                          // Update alarm setting
                        },
                        activeColor: AppColors.primaryLightBlue,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Format times for display
                        final bedHour = bedtime.hourOfPeriod;
                        final bedMinute = bedtime.minute.toString().padLeft(
                          2,
                          '0',
                        );
                        final bedPeriod =
                            bedtime.period == DayPeriod.am ? 'AM' : 'PM';

                        final wakeHour = wakeTime.hourOfPeriod;
                        final wakeMinute = wakeTime.minute.toString().padLeft(
                          2,
                          '0',
                        );
                        final wakePeriod =
                            wakeTime.period == DayPeriod.am ? 'AM' : 'PM';

                        setState(() {
                          sleepData["bedtime"] =
                              "$bedHour:$bedMinute $bedPeriod";
                          sleepData["wakeTime"] =
                              "$wakeHour:$wakeMinute $wakePeriod";
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Sleep schedule updated"),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddCaloriesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Calories"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddMealDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Add Meal"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddExerciseDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLightBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Add Exercise"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  void _showAddMealDialog() {
    String meal = "Breakfast";
    int calories = 350;
    TimeOfDay time = TimeOfDay.now();
    IconData mealIcon = Icons.free_breakfast;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Meal"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Meal type dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Meal Type",
                        ),
                        value: meal,
                        items: const [
                          DropdownMenuItem(
                            value: "Breakfast",
                            child: Text("Breakfast"),
                          ),
                          DropdownMenuItem(
                            value: "Morning Snack",
                            child: Text("Morning Snack"),
                          ),
                          DropdownMenuItem(
                            value: "Lunch",
                            child: Text("Lunch"),
                          ),
                          DropdownMenuItem(
                            value: "Afternoon Snack",
                            child: Text("Afternoon Snack"),
                          ),
                          DropdownMenuItem(
                            value: "Dinner",
                            child: Text("Dinner"),
                          ),
                          DropdownMenuItem(
                            value: "Evening Snack",
                            child: Text("Evening Snack"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            meal = value!;
                            // Set icon based on meal type
                            if (value == "Breakfast") {
                              mealIcon = Icons.free_breakfast;
                            } else if (value.contains("Snack")) {
                              mealIcon = Icons.apple;
                            } else if (value == "Lunch") {
                              mealIcon = Icons.lunch_dining;
                            } else if (value == "Dinner") {
                              mealIcon = Icons.dinner_dining;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Calories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Calories:"),
                          Text(
                            "$calories kcal",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: calories.toDouble(),
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        label: "$calories kcal",
                        activeColor: AppColors.primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            calories = value.round();
                          });
                        },
                      ),

                      // Time picker field
                      ListTile(
                        title: const Text("Time"),
                        subtitle: Text(
                          "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setState(() {
                              time = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add new meal
                        setState(() {
                          // Format time
                          final hour = time.hourOfPeriod;
                          final minute = time.minute.toString().padLeft(2, '0');
                          final period =
                              time.period == DayPeriod.am ? 'AM' : 'PM';

                          mealCalories.add({
                            "meal": meal,
                            "calories": calories,
                            "time": "$hour:$minute $period",
                            "icon": mealIcon,
                          });
                        });

                        Navigator.pop(context);

                        // If we opened from the Calories dialog, close that too
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added $calories kcal for $meal"),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddExerciseDialog() {
    String activity = "Running";
    int calories = 300;
    int duration = 30;
    TimeOfDay time = TimeOfDay.now();
    IconData exerciseIcon = Icons.directions_run;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Exercise"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Exercise type dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Exercise Type",
                        ),
                        value: activity,
                        items: const [
                          DropdownMenuItem(
                            value: "Running",
                            child: Text("Running"),
                          ),
                          DropdownMenuItem(
                            value: "Walking",
                            child: Text("Walking"),
                          ),
                          DropdownMenuItem(
                            value: "Cycling",
                            child: Text("Cycling"),
                          ),
                          DropdownMenuItem(
                            value: "Swimming",
                            child: Text("Swimming"),
                          ),
                          DropdownMenuItem(
                            value: "Weight Training",
                            child: Text("Weight Training"),
                          ),
                          DropdownMenuItem(value: "Yoga", child: Text("Yoga")),
                          DropdownMenuItem(value: "HIIT", child: Text("HIIT")),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            activity = value!;
                            // Set icon based on activity type
                            if (value == "Running") {
                              exerciseIcon = Icons.directions_run;
                            } else if (value == "Walking") {
                              exerciseIcon = Icons.directions_walk;
                            } else if (value == "Cycling") {
                              exerciseIcon = Icons.pedal_bike;
                            } else if (value == "Swimming") {
                              exerciseIcon = Icons.pool;
                            } else if (value == "Weight Training") {
                              exerciseIcon = Icons.fitness_center;
                            } else if (value == "Yoga") {
                              exerciseIcon = Icons.self_improvement;
                            } else if (value == "HIIT") {
                              exerciseIcon = Icons.timer;
                            } else {
                              exerciseIcon = Icons.sports;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Duration:"),
                          Text(
                            "$duration min",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLightBlue,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: duration.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        label: "$duration min",
                        activeColor: AppColors.primaryLightBlue,
                        onChanged: (value) {
                          setState(() {
                            duration = value.round();
                            // Automatically calculate calories based on duration and activity
                            calories = _calculateCaloriesBurned(
                              activity,
                              duration,
                            );
                          });
                        },
                      ),

                      // Calories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Calories Burned:"),
                          Text(
                            "$calories kcal",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLightBlue,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: calories.toDouble(),
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        label: "$calories kcal",
                        activeColor: AppColors.primaryLightBlue,
                        onChanged: (value) {
                          setState(() {
                            calories = value.round();
                          });
                        },
                      ),

                      // Time picker field
                      ListTile(
                        title: const Text("Time"),
                        subtitle: Text(
                          "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setState(() {
                              time = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add new exercise
                        setState(() {
                          // Format time
                          final hour = time.hourOfPeriod;
                          final minute = time.minute.toString().padLeft(2, '0');
                          final period =
                              time.period == DayPeriod.am ? 'AM' : 'PM';

                          exerciseCalories.add({
                            "activity": activity,
                            "calories": calories,
                            "time": "$hour:$minute $period",
                            "duration": "$duration min",
                            "icon": exerciseIcon,
                          });
                        });

                        Navigator.pop(context);

                        // If we opened from the Calories dialog, close that too
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Added $activity exercise burning $calories kcal",
                            ),
                            backgroundColor: AppColors.primaryLightBlue,
                          ),
                        );
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: AppColors.primaryLightBlue),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  int _calculateCaloriesBurned(String activity, int duration) {
    // Simple calorie calculation based on activity and duration
    // In a real app, this would consider user's weight, intensity, etc.
    switch (activity) {
      case "Running":
        return (duration * 10).round(); // About 10 calories per minute
      case "Walking":
        return (duration * 5).round(); // About 5 calories per minute
      case "Cycling":
        return (duration * 8).round(); // About 8 calories per minute
      case "Swimming":
        return (duration * 11).round(); // About 11 calories per minute
      case "Weight Training":
        return (duration * 6).round(); // About 6 calories per minute
      case "Yoga":
        return (duration * 4).round(); // About 4 calories per minute
      case "HIIT":
        return (duration * 12).round(); // About 12 calories per minute
      default:
        return (duration * 7).round(); // Default average
    }
  }
}

// Custom PieChart Painter for Nutrition Breakdown
class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Define pie chart sections with colors and percentages
    final sections = [
      {'color': const Color(0xFF42A5F5), 'percent': 0.5}, // Carbs (50%)
      {'color': const Color(0xFF1976D2), 'percent': 0.3}, // Protein (30%)
      {'color': const Color(0xFF0D47A1), 'percent': 0.2}, // Fat (20%)
    ];

    double startAngle = 0;

    // Draw each section
    for (final section in sections) {
      final sweepAngle = (section['percent'] as double) * 2 * 3.14159;
      final color = section['color'] as Color;

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw a white circle in the center for a donut chart effect
    final centerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
