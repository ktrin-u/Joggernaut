import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<int> weeklyData; 
  final int highlightDay; 
  final String title;

  const BarChartWidget({
    super.key,
    required this.weeklyData,
    required this.highlightDay,
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
            padding:  EdgeInsets.symmetric(vertical: screenHeight*0.01, horizontal: screenWidth*0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset:  Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight*0.001),
                  child: Text(
                    title,
                    style:  TextStyle(
                      fontFamily: "Roboto",
                      fontSize: screenWidth*0.06,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: BarChart(
                      BarChartData(
                        barTouchData: barTouchData,
                        titlesData: _titlesData(),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(),
                        gridData:  FlGridData(show: false),
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyData.reduce((a, b) => a > b ? a : b).toDouble() + 5,
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

  /// Defines the titles for the X-axis
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
      leftTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Custom X-Axis labels
  Widget getTitles(double value, TitleMeta meta) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final isHighlighted = value.toInt() == highlightDay;
    return Padding(
      padding:  EdgeInsets.only(top: 6.0),
      child: Text(
        days[value.toInt()],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? Color.fromRGBO(90, 155, 212, 1) : Colors.black87,
        ),
      ),
    );
  }

  /// Builds the bars dynamically based on steps data
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(weeklyData.length, (index) {
      final isHighlighted = index == highlightDay;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyData[index].toDouble(),
            gradient: isHighlighted ? _highlightGradient : _barsGradient,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  /// Gradient for normal bars
  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Color.fromRGBO(168, 230, 207, 1),
          Color.fromRGBO(168, 230, 207, 1),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  /// Gradient for the highlighted bar
  LinearGradient get _highlightGradient => LinearGradient(
        colors: [
          Color.fromRGBO(90, 155, 212, 1),
          Color.fromRGBO(90, 155, 212, 1),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  /// Tooltip and touch settings
  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
               TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );
}
