/// Production configuration constants.
///
/// Centralizes all environment-specific settings so they can be changed
/// in one place when building for production vs. development.
class AppConfig {
  AppConfig._();

  /// Whether the app is running in debug mode.
  static bool get isDebug {
    assert(() {
      return true;
    }());
    return false;
  }

  /// The base URL for exercise GIFs.
  ///
  /// Points at the upstream dataset's raw content on GitHub. In production,
  /// this should be replaced with a CDN URL for better performance and
  /// reliability.
  static const String gifBaseUrl =
      'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/';

  /// The database file name.
  static const String databaseName = 'fitness_app.db';

  /// Maximum number of exercises to load in a single query.
  static const int exerciseQueryLimit = 500;

  /// Maximum number of favorites to load.
  static const int favoritesLimit = 200;

  /// Maximum number of recently viewed exercises.
  static const int recentExercisesLimit = 20;

  /// Maximum number of workout sessions in history.
  static const int workoutHistoryLimit = 100;

  /// CachedNetworkImage cache duration (30 days).
  static const Duration imageCacheDuration = Duration(days: 30);

  /// CachedNetworkImage max cache width (pixels).
  static const int imageCacheWidth = 400;

  /// Whether to enable verbose logging.
  static const bool enableVerboseLogging = false;
}
