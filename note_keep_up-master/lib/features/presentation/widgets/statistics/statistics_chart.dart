import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../domain/entities/statistics.dart';

class StatisticsChart extends StatelessWidget {
  final NoteStatistics statistics;

  const StatisticsChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressChart(),
        const SizedBox(height: 20),
        _buildTimelineChart(),
      ],
    );
  }

  Widget _buildProgressChart() {
    return AspectRatio(
      aspectRatio: 2,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: statistics.completedTasks.toDouble(),
              title: 'Completed',
              color: Colors.green,
              radius: 50,
            ),
            PieChartSectionData(
              value: statistics.ongoingTasks.toDouble(),
              title: 'Ongoing',
              color: Colors.orange,
              radius: 50,
            ),
            PieChartSectionData(
              value: statistics.trashedTasks.toDouble(),
              title: 'Trashed',
              color: Colors.red,
              radius: 50,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildTimelineChart() {
    final List<FlSpot> spots = [];
    var index = 0.0;
    statistics.notesByDate.forEach((date, count) {
      spots.add(FlSpot(index, count.toDouble()));
      index++;
    });

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
