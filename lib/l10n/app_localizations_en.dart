// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get navHome => 'Home';

  @override
  String get navExercises => 'Exercises';

  @override
  String get navTrainingPlans => 'Training Plans';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get calendarSubtitle => 'Schedule workouts and track progress.';

  @override
  String get navDiet => 'Diet';

  @override
  String get dietSubtitle => 'Log meals and track your nutrition.';

  @override
  String get navBodyData => 'Body Data';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navRecent => 'Recent';

  @override
  String get navWorkoutHistory => 'Workout History';

  @override
  String get workoutHistorySubtitle => 'Review your past training sessions.';

  @override
  String get welcome => 'Welcome';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonSubtitle =>
      'The full dashboard lands in Phase 17. Each module (exercises, training, diet, body data, AI) is built in its own phase first.';

  @override
  String get exerciseLibrary => 'Exercise Library';

  @override
  String get exerciseLibrarySubtitle =>
      'Browse 1300+ exercises with GIF demos.';

  @override
  String get searchExercises => 'Search exercises';

  @override
  String get filter => 'Filter';

  @override
  String get bodyPart => 'Body Part';

  @override
  String get equipment => 'Equipment';

  @override
  String get clearAllFilters => 'Clear All Filters';

  @override
  String get noResults => 'No exercises found';

  @override
  String get noResultsSubtitle => 'Try adjusting your search or filters.';

  @override
  String get retry => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get howToPerform => 'How to perform';

  @override
  String get details => 'Details';

  @override
  String get target => 'Target';

  @override
  String get secondaryMuscles => 'Secondary Muscles';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get gifUnavailable => 'GIF unavailable';

  @override
  String get noInstructionsAvailable => 'No instructions available.';

  @override
  String get trainingPlans => 'Training Plans';

  @override
  String get trainingPlansSubtitle =>
      'Create and manage your workout routines.';

  @override
  String get newPlan => 'New plan';

  @override
  String get planName => 'Plan name';

  @override
  String get planDescription => 'Description (optional)';

  @override
  String get planGoal => 'Goal';

  @override
  String get daysPerWeek => 'Days per week';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get addDay => 'Add Day';

  @override
  String get dayName => 'Day name';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get weight => 'Weight';

  @override
  String get restSeconds => 'Rest (s)';

  @override
  String get notes => 'Notes';

  @override
  String deletePlanConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deletePlanWarning =>
      'This will permanently delete the plan and all its days and exercises.';

  @override
  String get planDuplicated => 'Plan duplicated';

  @override
  String get today => 'Today';

  @override
  String get weekView => 'Week view';

  @override
  String get monthView => 'Month view';

  @override
  String get scheduleWorkout => 'Schedule Workout';

  @override
  String get markRestDay => 'Mark Rest Day';

  @override
  String get restDay => 'Rest Day';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get markIncomplete => 'Mark Incomplete';

  @override
  String get remove => 'Remove';

  @override
  String get clear => 'Clear';

  @override
  String get noWorkoutScheduled => 'No workout scheduled';

  @override
  String get selectPlanAndDay => 'Select a plan and day to schedule';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get finishWorkoutConfirm => 'Finish Workout?';

  @override
  String get finishWorkoutWarning =>
      'This will finalize your workout session and mark it complete.';

  @override
  String get workoutCompleted => 'Workout completed!';

  @override
  String get abandonWorkout => 'Abandon Workout';

  @override
  String get abandonWorkoutConfirm => 'Abandon Workout?';

  @override
  String get abandonWorkoutWarning =>
      'This will discard the current session without saving.';

  @override
  String get totalVolume => 'Volume';

  @override
  String get completedSets => 'Sets';

  @override
  String get elapsedTime => 'Time';

  @override
  String get restTimer => 'Rest Timer';

  @override
  String get skip => 'Skip';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get add15s => '+15s';

  @override
  String get browseExercisesHint =>
      'Browse exercises and tap \"Add to plan\" to add here.';

  @override
  String get dietTracker => 'Diet Tracker';

  @override
  String get dietTrackerSubtitle => 'Log meals and track your nutrition.';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get addToBreakfast => 'Add to Breakfast';

  @override
  String get addToLunch => 'Add to Lunch';

  @override
  String get addToDinner => 'Add to Dinner';

  @override
  String get addToSnack => 'Add to Snack';

  @override
  String get foodName => 'Food name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get addRecord => 'Add Record';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get dietPlans => 'Diet Plans';

  @override
  String get newDietPlan => 'New plan';

  @override
  String get targetCalories => 'Target calories';

  @override
  String get targetProtein => 'Target protein';

  @override
  String get targetCarbs => 'Target carbs';

  @override
  String get targetFat => 'Target fat';

  @override
  String get activate => 'Activate';

  @override
  String get noDietPlans => 'No diet plans yet';

  @override
  String get noDietPlansSubtitle =>
      'Create a plan to set your daily nutrition targets.';

  @override
  String get bodyData => 'Body Data';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get noMeasurements => 'No measurements yet';

  @override
  String get noMeasurementsSubtitle =>
      'Add your first measurement to start tracking progress.';

  @override
  String get bmi => 'BMI';

  @override
  String get waist => 'Waist (cm)';

  @override
  String get chest => 'Chest (cm)';

  @override
  String get hip => 'Hip (cm)';

  @override
  String get arm => 'Arm (cm)';

  @override
  String get thigh => 'Thigh (cm)';

  @override
  String get progress => 'Progress';

  @override
  String get noProgressData => 'No progress data yet';

  @override
  String get noProgressDataSubtitle =>
      'Add body measurements to see your trends here.';

  @override
  String get current => 'Current';

  @override
  String get change => 'Change';

  @override
  String get start => 'Start';

  @override
  String get weightTrend => 'Weight Trend';

  @override
  String get notEnoughData => 'Not enough data to show trend';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get databaseInfo => 'Database info';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get openSource => 'Open source';

  @override
  String get exerciseDataGifs => 'Exercise data & GIFs';

  @override
  String get privacy => 'Privacy';

  @override
  String get glassShowcase => 'Glass Showcase';

  @override
  String get glassShowcaseSubtitle =>
      'Browse the Liquid Glass component gallery.';

  @override
  String get healthData => 'Health Data';

  @override
  String get healthToday => 'Today';

  @override
  String get healthSteps => 'Steps';

  @override
  String get healthActiveEnergy => 'Active Energy';

  @override
  String get healthHeartRate => 'Heart Rate';

  @override
  String get healthDistance => 'Distance';

  @override
  String get healthFlightsClimbed => 'Flights Climbed';

  @override
  String get healthConnectTitle => 'Connect to Apple Health';

  @override
  String get healthConnectSubtitle =>
      'Authorize access to your health data to see steps, heart rate, calories, and more.';

  @override
  String get healthConnect => 'Connect';

  @override
  String get healthSources => 'Data Sources';

  @override
  String get healthSourcesSubtitle =>
      'Data is read from Apple Health on iOS. On other platforms, mock data is shown for demonstration.';

  @override
  String get watchTitle => 'Apple Watch';

  @override
  String get watchConnected => 'Watch Connected';

  @override
  String get watchReachable => 'Watch is reachable';

  @override
  String get watchNotConnected => 'Watch Not Connected';

  @override
  String get watchNotAvailable =>
      'Apple Watch is not available on this platform.';

  @override
  String get watchNotPaired =>
      'No Apple Watch is paired. Pair your watch in the Watch app.';

  @override
  String get watchWorkoutSnapshot => 'Workout Snapshot';

  @override
  String get watchHeartRate => 'Heart Rate';

  @override
  String get watchCalories => 'Calories';

  @override
  String get watchProgress => 'Progress';

  @override
  String get watchSets => 'sets';

  @override
  String get watchElapsed => 'Elapsed';

  @override
  String get watchStartWorkout => 'Start Workout';

  @override
  String get watchStopWorkout => 'Stop Workout';

  @override
  String get watchPing => 'Ping Watch';

  @override
  String get watchDemoNote =>
      'On non-iOS platforms, mock data is shown for demonstration.';

  @override
  String get aiTrainingPlan => 'AI Training Plan';

  @override
  String get aiDietPlan => 'AI Diet Plan';

  @override
  String get aiGender => 'Gender';

  @override
  String get aiAge => 'Age';

  @override
  String get aiHeight => 'Height (cm)';

  @override
  String get aiWeight => 'Weight (kg)';

  @override
  String get aiExperience => 'Experience';

  @override
  String get aiGoal => 'Goal';

  @override
  String get aiDaysPerWeek => 'Days/Week';

  @override
  String get aiSessionDuration => 'Duration (min)';

  @override
  String get aiEquipment => 'Equipment';

  @override
  String get aiActivityLevel => 'Activity Level';

  @override
  String get aiGenerate => 'Generate';

  @override
  String get aiGenerating => 'AI is generating your plan...';

  @override
  String get aiPlanPreview => 'Plan Preview';

  @override
  String get aiMealSuggestions => 'Meal Suggestions';

  @override
  String get aiRegenerate => 'Regenerate';

  @override
  String get aiReset => 'Reset';

  @override
  String get aiTargetCalories => 'Target Calories';

  @override
  String get aiTargetProtein => 'Target Protein';

  @override
  String get aiTargetCarbs => 'Target Carbs';

  @override
  String get aiTargetFat => 'Target Fat';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionAvailable => 'Available Plans';

  @override
  String get subscriptionPurchase => 'Purchase';

  @override
  String get subscriptionRestore => 'Restore Purchases';

  @override
  String get subscriptionCurrent => 'Current Plan';

  @override
  String get subscriptionFeatures => 'Features';

  @override
  String get subscriptionFeatureExerciseLibrary => 'Exercise Library';

  @override
  String get subscriptionFeatureTrainingPlans => 'Training Plans';

  @override
  String get subscriptionFeatureAiTraining => 'AI Training Plans';

  @override
  String get subscriptionFeatureAiDiet => 'AI Diet Plans';

  @override
  String get subscriptionFeatureAnalytics => 'Advanced Analytics';

  @override
  String get subscriptionFeatureWatch => 'Apple Watch Features';

  @override
  String get subscriptionFeatureCloudSync => 'Cloud Sync';

  @override
  String get subscriptionFeaturePriorityAi => 'Priority AI';

  @override
  String get dashboardTodayWorkout => 'Today\'s Workout';

  @override
  String get dashboardNoWorkout => 'No workout scheduled. Tap to plan.';

  @override
  String get dashboardNoWorkoutToday => 'No Workout Today';

  @override
  String get dashboardScheduleWorkout => 'Schedule a workout';

  @override
  String get dashboardRestDay => 'Rest Day';

  @override
  String get dashboardEnjoyRest => 'Enjoy your recovery';

  @override
  String get dashboardStartWorkout => 'Start';

  @override
  String get dashboardQuickStats => 'Quick Stats';

  @override
  String get dashboardWorkouts => 'Workouts';

  @override
  String get dashboardVolume => 'Volume';

  @override
  String get dashboardWeight => 'Weight';

  @override
  String get dashboardSeeAll => 'See All';

  @override
  String get dashboardNoData => 'No data yet';

  @override
  String get dashboardAIPlans => 'AI Plans';

  @override
  String get dashboardAISubtitle => 'Generate personalized plans with AI';

  @override
  String get dashboardSubscription => 'Upgrade';

  @override
  String get dashboardSubscriptionSubtitle => 'Unlock AI, analytics, and more';

  @override
  String get gymVisualCopyright => '© Gym visual — gymvisual.com';
}
