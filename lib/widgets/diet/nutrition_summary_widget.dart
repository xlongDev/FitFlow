import 'package:flutter/material.dart';

import '../../models/diet_model.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// A card showing the day's nutrition summary with progress bars.
///
/// Displays total calories vs target, plus protein / carbs / fat breakdown.
/// Each macro has a colored progress bar showing consumed vs target.
class NutritionSummaryWidget extends StatelessWidget {
  const NutritionSummaryWidget({
    super.key,
    required this.summary,
    required this.plan,
  });

  final NutritionSummary summary;
  final DietPlanModel? plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetCalories = plan?.targetCalories ?? 2000;
    final targetProtein = plan?.targetProtein ?? 150;
    final targetCarbs = plan?.targetCarbs ?? 250;
    final targetFat = plan?.targetFat ?? 65;

    final caloriesProgress = (summary.totalCalories / targetCalories).clamp(0.0, 1.0);

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today', style: theme.textTheme.titleMedium),
              Text(
                '${summary.totalCalories.toStringAsFixed(0)} / ${targetCalories.toStringAsFixed(0)} kcal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Calories progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: caloriesProgress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _caloriesColor(caloriesProgress),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Macro breakdown
          Row(
            children: [
              Expanded(
                child: _MacroBar(
                  label: 'Protein',
                  value: summary.totalProtein,
                  target: targetProtein,
                  color: AppColors.primary,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MacroBar(
                  label: 'Carbs',
                  value: summary.totalCarbs,
                  target: targetCarbs,
                  color: AppColors.tertiary,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MacroBar(
                  label: 'Fat',
                  value: summary.totalFat,
                  target: targetFat,
                  color: AppColors.secondary,
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _caloriesColor(double progress) {
    if (progress < 0.5) return AppColors.tertiary;
    if (progress < 0.9) return AppColors.primary;
    if (progress <= 1.0) return AppColors.warning;
    return AppColors.error;
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    required this.unit,
  });

  final String label;
  final double value;
  final double target;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (value / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.xs3),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppSpacing.xs3),
        Text(
          '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
