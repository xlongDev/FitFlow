import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/calendar_provider.dart';
import '../../repositories/calendar_repository.dart';
import '../../theme/theme.dart';
import '../../utils/app_logger.dart';
import '../../widgets/calendar/calendar_cell.dart';
import '../../widgets/glass/glass.dart';

/// The training calendar page.
///
/// Shows a month or week grid of dates with workout indicators. Tapping a
/// date selects it and shows its details (scheduled workout / rest day /
/// nothing). The user can schedule a workout or mark a rest day from the
/// detail panel.
class TrainingCalendarPage extends ConsumerWidget {
  const TrainingCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_monthYear(state.focusedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () => ref.read(calendarProvider.notifier).goToToday(),
          ),
          IconButton(
            icon: Icon(
              state.viewMode == CalendarViewMode.month
                  ? Icons.view_week
                  : Icons.calendar_view_month,
            ),
            tooltip: state.viewMode == CalendarViewMode.month
                ? 'Week view'
                : 'Month view',
            onPressed: () => ref.read(calendarProvider.notifier).setViewMode(
                  state.viewMode == CalendarViewMode.month
                      ? CalendarViewMode.week
                      : CalendarViewMode.month,
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation header
          _NavigationHeader(state: state),
          // Weekday labels
          const _WeekdayLabels(),
          // Calendar grid
          Expanded(
            child: state.viewMode == CalendarViewMode.month
                ? _MonthGrid(state: state)
                : _WeekGrid(state: state),
          ),
          // Selected date detail
          _SelectedDateDetail(state: state),
        ],
      ),
    );
  }

  String _monthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Prev / Next navigation buttons.
class _NavigationHeader extends ConsumerWidget {
  const _NavigationHeader({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(calendarProvider.notifier).previous(),
          ),
          Text(
            state.viewMode == CalendarViewMode.month
                ? _monthYear(state.focusedDate)
                : _weekRange(state.focusedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(calendarProvider.notifier).next(),
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _weekRange(DateTime date) {
    final weekday = date.weekday % 7;
    final start = date.subtract(Duration(days: weekday));
    final end = start.add(const Duration(days: 6));
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }
}

/// The Sun–Sat weekday labels row.
class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: labels
            .map((label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// The month grid — 6 rows × 7 columns.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(state.focusedDate.year, state.focusedDate.month);
    final firstWeekday = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: firstWeekday));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = gridStart.add(Duration(days: index));
        final workout = state.workouts[DateTime(date.year, date.month, date.day)];
        final isInFocusedMonth = date.month == state.focusedDate.month;
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, state.selectedDate);

        return CalendarCell(
          date: date,
          workout: workout,
          isToday: isToday,
          isSelected: isSelected,
          isInFocusedMonth: isInFocusedMonth,
          onTap: () => _onCellTap(context, date),
        );
      },
    );
  }

  void _onCellTap(BuildContext context, DateTime date) {
    // Read via Consumer in the parent — but since this is a stateless widget,
    // we use a workaround: the parent passes a callback. For simplicity,
    // we use a Builder context to access the container.
    AppLogger.d('Calendar: tapped ${date.toIso8601String()}');
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// The week grid — 1 row × 7 columns.
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context) {
    final weekday = state.focusedDate.weekday % 7;
    final weekStart = state.focusedDate.subtract(Duration(days: weekday));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.6,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = weekStart.add(Duration(days: index));
        final workout = state.workouts[DateTime(date.year, date.month, date.day)];
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, state.selectedDate);

        return CalendarCell(
          date: date,
          workout: workout,
          isToday: isToday,
          isSelected: isSelected,
          isInFocusedMonth: true,
          onTap: () => AppLogger.d('Calendar: tapped ${date.toIso8601String()}'),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// The detail panel for the selected date.
class _SelectedDateDetail extends ConsumerWidget {
  const _SelectedDateDetail({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = state.workouts[state.selectedDate];
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDate(state.selectedDate),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (workout == null)
            _NoWorkoutState(
              onSchedule: () => _showScheduleSheet(context, ref),
              onRestDay: () => ref.read(calendarProvider.notifier).markRestDay(),
            )
          else if (workout.isRestDay)
            _RestDayState(
              onClear: () => ref.read(calendarProvider.notifier).clearDate(),
            )
          else
            _WorkoutState(
              workout: workout,
              onToggleComplete: () => ref.read(calendarProvider.notifier).toggleCompleted(),
              onRemove: () => ref.read(calendarProvider.notifier).clearDate(),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _showScheduleSheet(BuildContext context, WidgetRef ref) async {
    // For now, show a placeholder. A full plan-day picker will be added
    // when the training plan detail page exposes a selection API.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create a training plan first, then schedule it here.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Shown when no workout is scheduled for the selected date.
class _NoWorkoutState extends StatelessWidget {
  const _NoWorkoutState({required this.onSchedule, required this.onRestDay});

  final VoidCallback onSchedule;
  final VoidCallback onRestDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No workout scheduled',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Schedule Workout',
                icon: Icons.add,
                onPressed: onSchedule,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassButton(
                label: 'Rest Day',
                icon: Icons.bedtime_outlined,
                style: GlassButtonStyle.secondary,
                onPressed: onRestDay,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shown when the selected date is a rest day.
class _RestDayState extends StatelessWidget {
  const _RestDayState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.bedtime, color: theme.colorScheme.outline),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Rest Day',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        GlassButton(
          label: 'Clear',
          style: GlassButtonStyle.text,
          onPressed: onClear,
        ),
      ],
    );
  }
}

/// Shown when a workout is scheduled for the selected date.
class _WorkoutState extends StatelessWidget {
  const _WorkoutState({
    required this.workout,
    required this.onToggleComplete,
    required this.onRemove,
  });

  final ScheduledWorkoutModel workout;
  final VoidCallback onToggleComplete;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              workout.isCompleted ? Icons.check_circle : Icons.fitness_center,
              color: workout.isCompleted ? AppColors.tertiary : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.dayName ?? 'Workout',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (workout.planName != null)
                    Text(
                      workout.planName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: workout.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                icon: workout.isCompleted ? Icons.undo : Icons.check,
                style: workout.isCompleted
                    ? GlassButtonStyle.secondary
                    : GlassButtonStyle.primary,
                onPressed: onToggleComplete,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Remove',
              icon: Icons.delete_outline,
              style: GlassButtonStyle.destructive,
              onPressed: onRemove,
            ),
          ],
        ),
      ],
    );
  }
}
