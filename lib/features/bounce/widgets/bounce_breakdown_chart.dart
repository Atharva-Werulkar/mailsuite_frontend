import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';

/// Bounce Breakdown Chart Widget - Displays bounce types in a pie chart
class BounceBreakdownChart extends StatelessWidget {
  final Map<String, int> bouncesByType;

  const BounceBreakdownChart({
    super.key,
    required this.bouncesByType,
  });

  @override
  Widget build(BuildContext context) {
    final hard = bouncesByType[AppConstants.bounceTypeHard] ?? 0;
    final soft = bouncesByType[AppConstants.bounceTypeSoft] ?? 0;
    final unknown = bouncesByType[AppConstants.bounceTypeUnknown] ?? 0;
    final total = hard + soft + unknown;

    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No bounce data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    if (hard > 0)
                      PieChartSectionData(
                        value: hard.toDouble(),
                        title: '${((hard / total) * 100).toStringAsFixed(1)}%',
                        color: Colors.red,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (soft > 0)
                      PieChartSectionData(
                        value: soft.toDouble(),
                        title: '${((soft / total) * 100).toStringAsFixed(1)}%',
                        color: Colors.orange,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (unknown > 0)
                      PieChartSectionData(
                        value: unknown.toDouble(),
                        title: '${((unknown / total) * 100).toStringAsFixed(1)}%',
                        color: Colors.grey,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(hard, soft, unknown, total),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(int hard, int soft, int unknown, int total) {
    return Column(
      children: [
        if (hard > 0)
          _buildLegendItem(
            'Hard Bounces',
            hard,
            Colors.red,
          ),
        if (soft > 0)
          _buildLegendItem(
            'Soft Bounces',
            soft,
            Colors.orange,
          ),
        if (unknown > 0)
          _buildLegendItem(
            'Unknown',
            unknown,
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
