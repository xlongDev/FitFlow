import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/diet_model.dart';
import '../../providers/diet_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/diet/meal_editor_sheet.dart';
import '../../widgets/diet/nutrition_summary_widget.dart';
import '../../widgets/glass/glass.dart';

/// The diet page — daily food intake tracking.
///
/// Shows the selected date's nutrition summary at the top, followed by meal
/// sections (breakfast / lunch / dinner / snack). Each meal section lists
/// its food records and has an "add" button.
class DietPage extends ConsumerWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dietProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(state.selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref
                .read(dietProvider.notifier)
                .selectDate(state.selectedDate.subtract(const Duration(days: 1))),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () => ref
                .read(dietProvider.notifier)
                .selectDate(DateTime.now()),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref
                .read(dietProvider.notifier)
                .selectDate(state.selectedDate.add(const Duration(days: 1))),
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Diet Plans',
            onPressed: () => context.push(RouteNames.dietPlanPath),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: AppSpacing.xl2,
        ),
        children: [
          // Nutrition summary
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: NutritionSummaryWidget(
              summary: state.summary,
              plan: state.activePlan,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Meal sections
          for (final mealType in MealType.values)
            _MealSection(
              mealType: mealType,
              records: state.summary.byMealType[mealType] ?? [],
              date: state.selectedDate,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// A section showing all records for one meal type.
class _MealSection extends ConsumerWidget {
  const _MealSection({
    required this.mealType,
    required this.records,
    required this.date,
  });

  final MealType mealType;
  final List<DietRecordModel> records;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mealCalories = records.fold<double>(0, (sum, r) => sum + r.calories);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Row(
            children: [
              Icon(_mealIcon(mealType), size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _mealLabel(mealType),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (records.isNotEmpty)
                Text(
                  '${mealCalories.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _addRecord(context, ref),
              ),
            ],
          ),
          // Records
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'No items logged',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            for (final record in records)
              _RecordTile(
                record: record,
                onDelete: () => ref.read(dietProvider.notifier).removeRecord(record.id),
              ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _addRecord(BuildContext context, WidgetRef ref) async {
    final result = await MealEditorSheet.show(
      context,
      mealType: mealType,
      date: date,
    );
    if (result != null) {
      await ref.read(dietProvider.notifier).addRecord(result);
    }
  }

  IconData _mealIcon(MealType type) {
    return switch (type) {
      MealType.breakfast => Icons.wb_sunny,
      MealType.lunch => Icons.lunch_dining,
      MealType.dinner => Icons.dinner_dining,
      MealType.snack => Icons.cookie,
    };
  }

  String _mealLabel(MealType type) {
    return switch (type) {
      MealType.breakfast => 'Breakfast',
      MealType.lunch => 'Lunch',
      MealType.dinner => 'Dinner',
      MealType.snack => 'Snack',
    };
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDelete});

  final DietRecordModel record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.foodName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(
                    '${record.quantity.toStringAsFixed(0)}${record.unit} · '
                    '${record.calories.toStringAsFixed(0)} kcal · '
                    'P${record.protein.toStringAsFixed(0)} '
                    'C${record.carbs.toStringAsFixed(0)} '
                    'F${record.fat.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
