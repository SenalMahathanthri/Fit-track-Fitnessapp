import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';

class WeeklyProgressChart extends StatefulWidget {
  final List<Color> workoutGradientColors;
  final List<Color> targetGradientColors;
  final double height;

  const WeeklyProgressChart({
    super.key,
    required this.workoutGradientColors,
    required this.targetGradientColors,
    this.height = 250,
  });

  @override
  State<WeeklyProgressChart> createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends State<WeeklyProgressChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Legend for workout line
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.workoutGradientColors,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Workout Progress",
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Legend for target line
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.targetGradientColors,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Target",
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 15, left: 5),
              child: LineChart(mainData()),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.gray.withOpacity(0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: rightTitleWidgets,
            reservedSize: 40,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // Workout line
        LineChartBarData(
          spots: const [
            FlSpot(0, 35),
            FlSpot(1, 70),
            FlSpot(2, 40),
            FlSpot(3, 80),
            FlSpot(4, 25),
            FlSpot(5, 70),
            FlSpot(6, 35),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: widget.workoutGradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  widget.workoutGradientColors
                      .map((color) => color.withOpacity(0.2))
                      .toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Target line
        LineChartBarData(
          spots: const [
            FlSpot(0, 80),
            FlSpot(1, 50),
            FlSpot(2, 90),
            FlSpot(3, 40),
            FlSpot(4, 80),
            FlSpot(5, 35),
            FlSpot(6, 60),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: widget.targetGradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sun', style: style);
        break;
      case 1:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Tue', style: style);
        break;
      case 3:
        text = const Text('Wed', style: style);
        break;
      case 4:
        text = const Text('Thu', style: style);
        break;
      case 5:
        text = const Text('Fri', style: style);
        break;
      case 6:
        text = const Text('Sat', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.gray, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
