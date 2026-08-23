/// Centralized route name constants.
///
/// Using string constants (instead of raw strings) prevents typos in
/// `go_router` calls and makes route references greppable. Each route also
/// has a matching path in [AppRouter].
///
/// When adding a new page:
///   1. Add a name here.
///   2. Add a path + [GoRoute] entry in `app_router.dart`.
///   3. Add a strongly-typed navigation helper if needed.
class RouteNames {
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Top-level pages
  // ---------------------------------------------------------------------------

  /// The initial / splash-redirect route.
  static const String splash = 'splash';

  /// The main dashboard.
  static const String home = 'home';

  /// Exercise library (Phase 3).
  static const String exerciseLibrary = 'exercise-library';

  /// Exercise detail (Phase 4). Requires an exercise id.
  static const String exerciseDetail = 'exercise-detail';

  /// Favorites (Phase 5).
  static const String favorites = 'favorites';

  /// Recently viewed (Phase 5).
  static const String recentlyViewed = 'recently-viewed';

  /// Training plans (Phase 6).
  static const String trainingPlans = 'training-plans';

  /// Training plan detail (Phase 6). Requires a plan id.
  static const String trainingPlanDetail = 'training-plan-detail';

  /// Training calendar (Phase 7).
  static const String trainingCalendar = 'training-calendar';

  /// Workout session (Phase 8) — the live workout experience.
  static const String workoutSession = 'workout-session';

  /// Workout history (Phase 8).
  static const String workoutHistory = 'workout-history';

  /// Health data (Phase 13).
  static const String healthData = 'health-data';

  /// Apple Watch status (Phase 14).
  static const String watchStatus = 'watch-status';

  /// AI training plan (Phase 15).
  static const String aiTrainingPlan = 'ai-training-plan';

  /// AI diet plan (Phase 15).
  static const String aiDietPlan = 'ai-diet-plan';

  /// Subscription (Phase 16).
  static const String subscription = 'subscription';

  /// Diet (Phase 9).
  static const String diet = 'diet';

  /// Diet plan (Phase 9).
  static const String dietPlan = 'diet-plan';

  /// Body data (Phase 10).
  static const String bodyData = 'body-data';

  /// Progress (Phase 10).
  static const String progress = 'progress';

  /// Settings.
  static const String settings = 'settings';

  /// Glass component showcase (Phase 1) — dev / QA only.
  static const String glassShowcase = 'glass-showcase';

  // ---------------------------------------------------------------------------
  // Paths — kept in sync with [AppRouter].
  // ---------------------------------------------------------------------------

  static const String splashPath = '/splash';
  static const String homePath = '/';
  static const String glassShowcasePath = '/glass-showcase';
  static const String exerciseLibraryPath = '/exercises';
  static const String exerciseDetailPath = '/exercises/:id';
  static const String favoritesPath = '/favorites';
  static const String recentlyViewedPath = '/recently-viewed';
  static const String trainingPlansPath = '/training-plans';
  static const String trainingPlanDetailPath = '/training-plans/:id';
  static const String trainingCalendarPath = '/training-calendar';
  static const String workoutSessionPath = '/workout-session';
  static const String workoutHistoryPath = '/workout-history';
  static const String healthDataPath = '/health-data';
  static const String watchStatusPath = '/watch-status';
  static const String aiTrainingPlanPath = '/ai-training-plan';
  static const String aiDietPlanPath = '/ai-diet-plan';
  static const String subscriptionPath = '/subscription';
  static const String dietPath = '/diet';
  static const String dietPlanPath = '/diet-plan';
  static const String bodyDataPath = '/body-data';
  static const String progressPath = '/progress';
  static const String settingsPath = '/settings';
}
