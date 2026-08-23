import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/calendar_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// The calendar view mode.
enum CalendarViewMode { month, week }

/// Immutable state for the calendar page.
class CalendarState {
  const CalendarState({
    required this.focusedDate,
    required this.selectedDate,
    required this.viewMode,
    required this.workouts,
  });

  /// The month / week currently being viewed (navigation target).
  final DateTime focusedDate;

  /// The date the user tapped (for the detail panel).
  final DateTime selectedDate;

  /// Month or week view.
  final CalendarViewMode viewMode;

  /// All scheduled workouts for the visible range, keyed by date.
  final Map<DateTime, ScheduledWorkoutModel> workouts;

  CalendarState copyWith({
    DateTime? focusedDate,
    DateTime? selectedDate,
    CalendarViewMode? viewMode,
    Map<DateTime, ScheduledWorkoutModel>? workouts,
  }) {
    return CalendarState(
      focusedDate: focusedDate ?? this.focusedDate,
      selectedDate: selectedDate ?? this.selectedDate,
      viewMode: viewMode ?? this.viewMode,
      workouts: workouts ?? this.workouts,
    );
  }
}

/// Notifier that manages the calendar page state.
class CalendarNotifier extends Notifier<CalendarState> {
  late CalendarRepository _repo;

  @override
  CalendarState build() {
    _repo = ref.watch(calendarRepositoryProvider);

    final today = _normalizeDate(DateTime.now());
    final initial = CalendarState(
      focusedDate: today,
      selectedDate: today,
      viewMode: CalendarViewMode.month,
      workouts: const <DateTime, ScheduledWorkoutModel>{},
    );

    // Kick off the initial load.
    unawaited(_loadVisibleRange(initial));
    return initial;
  }

  /// Moves the focused date to the previous month / week.
  Future<void> previous() async {
    final newFocused = state.viewMode == CalendarViewMode.month
        ? DateTime(state.focusedDate.year, state.focusedDate.month - 1)
        : state.focusedDate.subtract(const Duration(days: 7));
    state = state.copyWith(focusedDate: newFocused);
    await _loadVisibleRange(state);
  }

  /// Moves the focused date to the next month / week.
  Future<void> next() async {
    final newFocused = state.viewMode == CalendarViewMode.month
        ? DateTime(state.focusedDate.year, state.focusedDate.month + 1)
        : state.focusedDate.add(const Duration(days: 7));
    state = state.copyWith(focusedDate: newFocused);
    await _loadVisibleRange(state);
  }

  /// Jumps to today.
  Future<void> goToToday() async {
    final today = _normalizeDate(DateTime.now());
    state = state.copyWith(focusedDate: today, selectedDate: today);
    await _loadVisibleRange(state);
  }

  /// Selects a date (tapped cell).
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: _normalizeDate(date));
  }

  /// Switches between month and week view.
  Future<void> setViewMode(CalendarViewMode mode) async {
    state = state.copyWith(viewMode: mode);
    await _loadVisibleRange(state);
  }

  /// Schedules a workout on the selected date.
  Future<void> scheduleWorkout({
    required String planId,
    required String planDayId,
  }) async {
    await _repo.scheduleWorkout(
      date: state.selectedDate,
      planId: planId,
      planDayId: planDayId,
    );
    await _loadVisibleRange(state);
  }

  /// Marks the selected date as a rest day.
  Future<void> markRestDay() async {
    await _repo.markRestDay(state.selectedDate);
    await _loadVisibleRange(state);
  }

  /// Clears the schedule for the selected date.
  Future<void> clearDate() async {
    await _repo.clearDate(state.selectedDate);
    await _loadVisibleRange(state);
  }

  /// Toggles the completed state of the selected date's workout.
  Future<void> toggleCompleted() async {
    await _repo.toggleCompleted(state.selectedDate);
    await _loadVisibleRange(state);
  }

  /// Loads all workouts for the visible range into [state.workouts].
  Future<void> _loadVisibleRange(CalendarState s) async {
    try {
      final (start, end) = _visibleRange(s);
      final workouts = await _repo.getRange(start, end);
      if (!ref.mounted) return;

      final map = <DateTime, ScheduledWorkoutModel>{};
      for (final w in workouts) {
        map[_normalizeDate(w.date)] = w;
      }
      state = s.copyWith(workouts: map);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Calendar: failed to load range', e, st);
    }
  }

  /// Returns the inclusive (start, end) range for the current view mode.
  (DateTime, DateTime) _visibleRange(CalendarState s) {
    if (s.viewMode == CalendarViewMode.month) {
      // Show the full calendar grid — include leading/trailing days from
      // adjacent months so the grid is always 6 rows × 7 columns.
      final firstOfMonth = DateTime(s.focusedDate.year, s.focusedDate.month);
      final firstWeekday = firstOfMonth.weekday % 7; // Sun = 0
      final gridStart = firstOfMonth.subtract(Duration(days: firstWeekday));
      final gridEnd = gridStart.add(const Duration(days: 41));
      return (gridStart, gridEnd);
    } else {
      // Week view: 7 days starting from the Sunday of the focused week.
      final focusedWeekday = s.focusedDate.weekday % 7;
      final weekStart =
          s.focusedDate.subtract(Duration(days: focusedWeekday));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return (weekStart, weekEnd);
    }
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// Provider that exposes the [CalendarNotifier].
final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);
