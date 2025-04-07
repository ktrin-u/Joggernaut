import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<(DateTime, int)> workoutData; // List containing (DateTime, Steps)
  final String title;

  const BarChartWidget({
    super.key,
    required this.workoutData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                  child: Text(
                    "Step Chart (last 7 sessions)",
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: BarChart(
                      BarChartData(
                        titlesData: _titlesData(),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(),
                        gridData: FlGridData(show: false),
                        alignment: BarChartAlignment.spaceAround,
                        maxY: workoutData.isNotEmpty
                                ? (workoutData.map((e) => e.$2).reduce((a, b) => a > b ? a : b) + 1000)
                                : 1000,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Defines the titles for the X-axis with DateTime formatting
  FlTitlesData _titlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: getTitles,
        ),
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Custom X-Axis labels using DateTime (MM/dd format)
  Widget getTitles(double value, TitleMeta meta) {
    int index = value.toInt();
  
    if (index >= 0 && index < workoutData.length) {
      DateTime date = workoutData[index].$1; // Extract DateTime from tuple
      String formattedDate = "${date.month}/${date.day}"; // Format as MM/dd

      return Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
    }
    return Container();
  }

  /// Builds the bars dynamically based on steps data
  List<BarChartGroupData> _buildBarGroups() {
    if (workoutData.isEmpty) {
      return []; // Return an empty list if no data
    }

    return List.generate(workoutData.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: workoutData[index].$2.toDouble(),
            gradient: _barsGradient,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  /// Gradient for normal bars
  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Color.fromRGBO(153, 186, 221, 1),
          Color.fromRGBO(30, 144, 255, 1),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  
}
