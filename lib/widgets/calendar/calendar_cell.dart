import 'package:flutter/material.dart';

import '../../repositories/calendar_repository.dart';
import '../../theme/theme.dart';

/// A single day cell in the calendar grid.
///
/// Renders the day number and a colored indicator showing the workout state:
///   * Filled accent dot — scheduled workout (not completed).
///   * Filled green dot — completed workout.
///   * Grey "R" — rest day.
///   * Nothing — no schedule.
///
/// The cell highlights when it's [isSelected] or [isToday].
class CalendarCell extends StatelessWidget {
  const CalendarCell({
    super.key,
    required this.date,
    required this.workout,
    required this.isToday,
    required this.isSelected,
    required this.isInFocusedMonth,
    required this.onTap,
  });

  final DateTime date;
  final ScheduledWorkoutModel? workout;
  final bool isToday;
  final bool isSelected;
  final bool isInFocusedMonth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isInFocusedMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outline,
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            _Indicator(workout: workout),
          ],
        ),
      ),
    );
  }
}

/// The colored dot / label under the day number.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.workout});

  final ScheduledWorkoutModel? workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (workout == null) {
      return const SizedBox(width: 6, height: 6);
    }

    if (workout!.isRestDay) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'R',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: workout!.isCompleted ? AppColors.tertiary : AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
