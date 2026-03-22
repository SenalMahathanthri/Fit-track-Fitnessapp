// lib/view/home/activity_tracker_view.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ActivityTrackerView extends StatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  State<ActivityTrackerView> createState() => _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends State<ActivityTrackerView> {
  int touchedIndex = -1;
  List latestActivities = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              // Show more options
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              // Today Target Card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLightBlue.withOpacity(0.3),
                      AppColors.primaryBlue.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Target",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.blueGradient,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              height: 30,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              textColor: AppColors.primaryBlue,
                              minWidth: double.maxFinite,
                              elevation: 0,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            value: "8L",
                            title: "Water Intake",
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/foot.png",
                            value: "2400",
                            title: "Foot Steps",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: media.width * 0.1),

              // Activity Progress Chart Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Activity Progress",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.blueGradient,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items:
                            ["Weekly", "Monthly"]
                                .map(
                                  (name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {},
                        icon: const Icon(
                          Icons.expand_more,
                          color: AppColors.white,
                        ),
                        hint: const Text(
                          "Weekly",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: media.width * 0.05),

              // Activity Progress Bar Chart
              Container(
                height: media.width * 0.5,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.grey,
                        tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                        tooltipMargin: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String weekDay;
                          switch (group.x) {
                            case 0:
                              weekDay = 'Monday';
                              break;
                            case 1:
                              weekDay = 'Tuesday';
                              break;
                            case 2:
                              weekDay = 'Wednesday';
                              break;
                            case 3:
                              weekDay = 'Thursday';
                              break;
                            case 4:
                              weekDay = 'Friday';
                              break;
                            case 5:
                              weekDay = 'Saturday';
                              break;
                            case 6:
                              weekDay = 'Sunday';
                              break;
                            default:
                              throw Error();
                          }
                          return BarTooltipItem(
                            '$weekDay\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: (rod.toY - 1).toString(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getTitles,
                          reservedSize: 38,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: showingGroups(),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),

              SizedBox(height: media.width * 0.05),

              // Latest Activities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Latest Activity",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See More",
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: latestActivities.length,
                itemBuilder: (context, index) {
                  var activity = latestActivities[index] as Map? ?? {};
                  return LatestActivityRow(activity: activity);
                },
              ),

              SizedBox(height: media.width * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.gray,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('Sun', style: style);
        break;
      case 1:
        text = Text('Mon', style: style);
        break;
      case 2:
        text = Text('Tue', style: style);
        break;
      case 3:
        text = Text('Wed', style: style);
        break;
      case 4:
        text = Text('Thu', style: style);
        break;
      case 5:
        text = Text('Fri', style: style);
        break;
      case 6:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 16, child: text);
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    switch (i) {
      case 0:
        return makeGroupData(
          0,
          5,
          AppColors.blueGradient,
          isTouched: i == touchedIndex,
        );
      case 1:
        return makeGroupData(
          1,
          10.5,
          AppColors.purpleGradient,
          isTouched: i == touchedIndex,
        );
      case 2:
        return makeGroupData(
          2,
          5,
          AppColors.blueGradient,
          isTouched: i == touchedIndex,
        );
      case 3:
        return makeGroupData(
          3,
          7.5,
          AppColors.purpleGradient,
          isTouched: i == touchedIndex,
        );
      case 4:
        return makeGroupData(
          4,
          15,
          AppColors.blueGradient,
          isTouched: i == touchedIndex,
        );
      case 5:
        return makeGroupData(
          5,
          5.5,
          AppColors.purpleGradient,
          isTouched: i == touchedIndex,
        );
      case 6:
        return makeGroupData(
          6,
          8.5,
          AppColors.blueGradient,
          isTouched: i == touchedIndex,
        );
      default:
        return throw Error();
    }
  });

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(
            colors: barColor,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: width,
          borderSide:
              isTouched
                  ? const BorderSide(color: Colors.green)
                  : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: AppColors.cardBackground,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}

// Today Target Cell Widget
class TodayTargetCell extends StatelessWidget {
  final String icon;
  final String value;
  final String title;

  const TodayTargetCell({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 30, height: 30, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Latest Activity Row Widget
class LatestActivityRow extends StatelessWidget {
  final Map activity;
  const LatestActivityRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              activity["image"].toString(),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity["title"].toString(),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  activity["time"].toString(),
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
