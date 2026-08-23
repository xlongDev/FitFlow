import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/body_metric_model.dart';
import '../../theme/theme.dart';

/// A line chart showing a body metric's trend over time.
///
/// Renders a smooth line connecting all data points, with the y-axis showing
/// the metric value and the x-axis showing dates. Used on the progress page
/// to visualize weight / body fat / circumference changes.
class BodyMetricChart extends StatelessWidget {
  const BodyMetricChart({
    super.key,
    required this.records,
    required this.valueExtractor,
    required this.unit,
    required this.color,
  });

  /// The records to plot (oldest first for correct x-axis ordering).
  final List<BodyMetricModel> records;

  /// Extracts the numeric value to plot from each record.
  final double? Function(BodyMetricModel) valueExtractor;

  /// The unit label (e.g. 'kg', '%', 'cm').
  final String unit;

  /// The line color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out records where the value is null.
    final points = <FlSpot>[];
    for (var i = 0; i < records.length; i++) {
      final v = valueExtractor(records[i]);
      if (v != null) {
        points.add(FlSpot(i.toDouble(), v));
      }
    }

    if (points.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Not enough data to show trend',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    final minY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;
    final chartMinY = (minY - padding).floorToDouble();
    final chartMaxY = (maxY + padding).ceilToDouble();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: LineChart(
          LineChartData(
            minY: chartMinY,
            maxY: chartMaxY,
            minX: 0,
            maxX: (points.length - 1).toDouble(),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: (chartMaxY - chartMinY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                
              ),
              rightTitles: const AxisTitles(
                
              ),
              bottomTitles: const AxisTitles(
                
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (chartMaxY - chartMinY) / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                curveSmoothness: 0.3,
                preventCurveOverShooting: true,
                color: color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} $unit',
                      theme.textTheme.labelMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
