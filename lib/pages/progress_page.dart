import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/body_metric_model.dart';
import '../../providers/body_metric_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/body/body_metric_chart.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The progress page — visualizes body metric trends over time.
///
/// Shows a line chart for weight (the primary metric), plus summary cards
/// with the latest value, total change, and percentage change.
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(bodyMetricHistoryProvider);
    final bodyState = ref.watch(bodyDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: asyncHistory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(bodyMetricHistoryProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.show_chart,
              title: 'No progress data yet',
              subtitle: 'Add body measurements to see your trends here.',
            );
          }

          // Reverse to oldest-first for the chart.
          final chronological = records.reversed.toList();

          return ListView(
            padding: const EdgeInsets.only(
              left: AppSpacing.pageHorizontal,
              right: AppSpacing.pageHorizontal,
              bottom: AppSpacing.xl2,
            ),
            children: [
              // Weight trend chart
              _ChartCard(
                title: 'Weight Trend',
                unit: 'kg',
                color: AppColors.primary,
                records: chronological,
                valueExtractor: (m) => m.weight,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Summary cards
              if (bodyState is BodyDataData && bodyState.weightTrend != null)
                _SummaryCards(trend: bodyState.weightTrend!),

              const SizedBox(height: AppSpacing.lg),

              // Body fat chart (if available)
              if (records.any((r) => r.bodyFat != null)) ...[
                _ChartCard(
                  title: 'Body Fat Trend',
                  unit: '%',
                  color: AppColors.secondary,
                  records: chronological,
                  valueExtractor: (m) => m.bodyFat,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Waist chart (if available)
              if (records.any((r) => r.waist != null)) ...[
                _ChartCard(
                  title: 'Waist Trend',
                  unit: 'cm',
                  color: AppColors.tertiary,
                  records: chronological,
                  valueExtractor: (m) => m.waist,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.unit,
    required this.color,
    required this.records,
    required this.valueExtractor,
  });

  final String title;
  final String unit;
  final Color color;
  final List<BodyMetricModel> records;
  final double? Function(BodyMetricModel) valueExtractor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          BodyMetricChart(
            records: records,
            valueExtractor: valueExtractor,
            unit: unit,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.trend});

  final MetricTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDecrease = trend.change < 0;
    final changeColor = isDecrease ? AppColors.tertiary : AppColors.secondary;
    final changeText = '${isDecrease ? '↓' : '↑'} ${trend.change.abs().toStringAsFixed(1)} kg';
    final percentText = '${trend.percentChange >= 0 ? '+' : ''}${trend.percentChange.toStringAsFixed(1)}%';

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Current',
            value: '${trend.latest.toStringAsFixed(1)} kg',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Change',
            value: changeText,
            subValue: percentText,
            color: changeColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Start',
            value: '${trend.first.toStringAsFixed(1)} kg',
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    this.subValue,
  });

  final String label;
  final String value;
  final Color color;
  final String? subValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          if (subValue != null) ...[
            const SizedBox(height: AppSpacing.xs3),
            Text(
              subValue!,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
          const SizedBox(height: AppSpacing.xs3),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
