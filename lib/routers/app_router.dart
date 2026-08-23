import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/ai_diet_plan_page.dart';
import '../pages/ai_training_plan_page.dart';
import '../pages/body_data_page.dart';
import '../pages/diet_page.dart';
import '../pages/diet_plan_page.dart';
import '../pages/exercise_detail_page.dart';
import '../pages/exercise_library_page.dart';
import '../pages/favorite_page.dart';
import '../pages/glass_showcase_page.dart';
import '../pages/health_data_page.dart';
import '../pages/home_page.dart';
import '../pages/progress_page.dart';
import '../pages/recently_viewed_page.dart';
import '../pages/settings_page.dart';
import '../pages/splash_page.dart';
import '../pages/subscription_page.dart';
import '../pages/training_calendar_page.dart';
import '../pages/training_plan_detail_page.dart';
import '../pages/training_plan_page.dart';
import '../pages/watch_status_page.dart';
import '../pages/workout_history_page.dart';
import '../pages/workout_session_page.dart';
import 'route_names.dart';

/// Provider that exposes the configured [GoRouter].
///
/// Using a Riverpod provider (instead of a global singleton) means the router
/// can react to auth / entitlement state changes in future phases by
/// `ref.watch`-ing those providers inside [GoRouter.refreshListenable].
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

/// Centralized router configuration.
///
/// All routes live here — pages must NOT call `Navigator.push` directly.
/// This keeps navigation greppable, deep-link friendly, and ready for
/// future auth / entitlement gating.
///
/// Strong typing: navigation helpers (e.g. [goHome]) accept typed parameters
/// so callers can't pass the wrong path-parameter type.
class AppRouter {
  AppRouter(this._ref);

  // Stored for future auth / entitlement redirect logic. Read via `ref.watch`
  // inside a `redirect` callback once those providers exist (Phase 16+).
  // ignore: unused_field
  final Ref _ref;

  // ---------------------------------------------------------------------------
  // Router instance
  // ---------------------------------------------------------------------------

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
    // Future: redirect based on auth / entitlement state.
    // redirect: (context, state) => ...,
  );

  // ---------------------------------------------------------------------------
  // Route table
  // ---------------------------------------------------------------------------

  List<RouteBase> get _routes => [
        GoRoute(
          name: RouteNames.splash,
          path: RouteNames.splashPath,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          name: RouteNames.home,
          path: RouteNames.homePath,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: RouteNames.settings,
          path: RouteNames.settingsPath,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          name: RouteNames.glassShowcase,
          path: RouteNames.glassShowcasePath,
          builder: (context, state) => const GlassShowcasePage(),
        ),
        GoRoute(
          name: RouteNames.exerciseLibrary,
          path: RouteNames.exerciseLibraryPath,
          builder: (context, state) => const ExerciseLibraryPage(),
        ),
        GoRoute(
          name: RouteNames.exerciseDetail,
          path: RouteNames.exerciseDetailPath,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) {
              return const _ErrorPage(error: null);
            }
            return ExerciseDetailPage(exerciseId: id);
          },
        ),
        GoRoute(
          name: RouteNames.favorites,
          path: RouteNames.favoritesPath,
          builder: (context, state) => const FavoritePage(),
        ),
        GoRoute(
          name: RouteNames.recentlyViewed,
          path: RouteNames.recentlyViewedPath,
          builder: (context, state) => const RecentlyViewedPage(),
        ),
        GoRoute(
          name: RouteNames.trainingPlans,
          path: RouteNames.trainingPlansPath,
          builder: (context, state) => const TrainingPlanPage(),
        ),
        GoRoute(
          name: RouteNames.trainingPlanDetail,
          path: RouteNames.trainingPlanDetailPath,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) {
              return const _ErrorPage(error: null);
            }
            return TrainingPlanDetailPage(planId: id);
          },
        ),
        GoRoute(
          name: RouteNames.trainingCalendar,
          path: RouteNames.trainingCalendarPath,
          builder: (context, state) => const TrainingCalendarPage(),
        ),
        GoRoute(
          name: RouteNames.workoutSession,
          path: RouteNames.workoutSessionPath,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return WorkoutSessionPage(
              scheduledWorkoutId: extra?['scheduledWorkoutId'] as String?,
              planDayId: extra?['planDayId'] as String?,
              planId: extra?['planId'] as String?,
              planName: extra?['planName'] as String?,
              dayName: extra?['dayName'] as String?,
            );
          },
        ),
        GoRoute(
          name: RouteNames.workoutHistory,
          path: RouteNames.workoutHistoryPath,
          builder: (context, state) => const WorkoutHistoryPage(),
        ),
        GoRoute(
          name: RouteNames.diet,
          path: RouteNames.dietPath,
          builder: (context, state) => const DietPage(),
        ),
        GoRoute(
          name: RouteNames.dietPlan,
          path: RouteNames.dietPlanPath,
          builder: (context, state) => const DietPlanPage(),
        ),
        GoRoute(
          name: RouteNames.bodyData,
          path: RouteNames.bodyDataPath,
          builder: (context, state) => const BodyDataPage(),
        ),
        GoRoute(
          name: RouteNames.progress,
          path: RouteNames.progressPath,
          builder: (context, state) => const ProgressPage(),
        ),
        GoRoute(
          name: RouteNames.healthData,
          path: RouteNames.healthDataPath,
          builder: (context, state) => const HealthDataPage(),
        ),
        GoRoute(
          name: RouteNames.watchStatus,
          path: RouteNames.watchStatusPath,
          builder: (context, state) => const WatchStatusPage(),
        ),
        GoRoute(
          name: RouteNames.aiTrainingPlan,
          path: RouteNames.aiTrainingPlanPath,
          builder: (context, state) => const AITrainingPlanPage(),
        ),
        GoRoute(
          name: RouteNames.aiDietPlan,
          path: RouteNames.aiDietPlanPath,
          builder: (context, state) => const AIDietPlanPage(),
        ),
        GoRoute(
          name: RouteNames.subscription,
          path: RouteNames.subscriptionPath,
          builder: (context, state) => const SubscriptionPage(),
        ),
      ];

  // ---------------------------------------------------------------------------
  // Strongly-typed navigation helpers
  // ---------------------------------------------------------------------------

  /// Navigate to the home dashboard.
  void goHome(BuildContext context) => context.go(RouteNames.homePath);

  /// Navigate to settings.
  void goSettings(BuildContext context) => context.go(RouteNames.settingsPath);

  /// Push the settings page on top of the current route.
  void pushSettings(BuildContext context) =>
      context.push(RouteNames.settingsPath);
}

/// Fallback page shown when a route cannot be resolved.
///
/// This should never be visible to users in production — it indicates a
/// programming error (a bad `context.go` call). Kept user-friendly so that
/// if it ever does show, the app doesn't look broken.
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown navigation error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
