import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The app's display name
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navExercises;

  /// No description provided for @navTrainingPlans.
  ///
  /// In en, this message translates to:
  /// **'Training Plans'**
  String get navTrainingPlans;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule workouts and track progress.'**
  String get calendarSubtitle;

  /// No description provided for @navDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get navDiet;

  /// No description provided for @dietSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log meals and track your nutrition.'**
  String get dietSubtitle;

  /// No description provided for @navBodyData.
  ///
  /// In en, this message translates to:
  /// **'Body Data'**
  String get navBodyData;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get navRecent;

  /// No description provided for @navWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get navWorkoutHistory;

  /// No description provided for @workoutHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your past training sessions.'**
  String get workoutHistorySubtitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The full dashboard lands in Phase 17. Each module (exercises, training, diet, body data, AI) is built in its own phase first.'**
  String get comingSoonSubtitle;

  /// No description provided for @exerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// No description provided for @exerciseLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse 1300+ exercises with GIF demos.'**
  String get exerciseLibrarySubtitle;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get searchExercises;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @bodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPart;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noResults;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get noResultsSubtitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @howToPerform.
  ///
  /// In en, this message translates to:
  /// **'How to perform'**
  String get howToPerform;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @secondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get secondaryMuscles;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @gifUnavailable.
  ///
  /// In en, this message translates to:
  /// **'GIF unavailable'**
  String get gifUnavailable;

  /// No description provided for @noInstructionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No instructions available.'**
  String get noInstructionsAvailable;

  /// No description provided for @trainingPlans.
  ///
  /// In en, this message translates to:
  /// **'Training Plans'**
  String get trainingPlans;

  /// No description provided for @trainingPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage your workout routines.'**
  String get trainingPlansSubtitle;

  /// No description provided for @newPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newPlan;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get planName;

  /// No description provided for @planDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get planDescription;

  /// No description provided for @planGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get planGoal;

  /// No description provided for @daysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Days per week'**
  String get daysPerWeek;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addDay.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get addDay;

  /// No description provided for @dayName.
  ///
  /// In en, this message translates to:
  /// **'Day name'**
  String get dayName;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @restSeconds.
  ///
  /// In en, this message translates to:
  /// **'Rest (s)'**
  String get restSeconds;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @deletePlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deletePlanConfirm(String name);

  /// No description provided for @deletePlanWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the plan and all its days and exercises.'**
  String get deletePlanWarning;

  /// No description provided for @planDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Plan duplicated'**
  String get planDuplicated;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week view'**
  String get weekView;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month view'**
  String get monthView;

  /// No description provided for @scheduleWorkout.
  ///
  /// In en, this message translates to:
  /// **'Schedule Workout'**
  String get scheduleWorkout;

  /// No description provided for @markRestDay.
  ///
  /// In en, this message translates to:
  /// **'Mark Rest Day'**
  String get markRestDay;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDay;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @markIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Incomplete'**
  String get markIncomplete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noWorkoutScheduled.
  ///
  /// In en, this message translates to:
  /// **'No workout scheduled'**
  String get noWorkoutScheduled;

  /// No description provided for @selectPlanAndDay.
  ///
  /// In en, this message translates to:
  /// **'Select a plan and day to schedule'**
  String get selectPlanAndDay;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @finishWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout?'**
  String get finishWorkoutConfirm;

  /// No description provided for @finishWorkoutWarning.
  ///
  /// In en, this message translates to:
  /// **'This will finalize your workout session and mark it complete.'**
  String get finishWorkoutWarning;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout completed!'**
  String get workoutCompleted;

  /// No description provided for @abandonWorkout.
  ///
  /// In en, this message translates to:
  /// **'Abandon Workout'**
  String get abandonWorkout;

  /// No description provided for @abandonWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Abandon Workout?'**
  String get abandonWorkoutConfirm;

  /// No description provided for @abandonWorkoutWarning.
  ///
  /// In en, this message translates to:
  /// **'This will discard the current session without saving.'**
  String get abandonWorkoutWarning;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get totalVolume;

  /// No description provided for @completedSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get completedSets;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get elapsedTime;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @add15s.
  ///
  /// In en, this message translates to:
  /// **'+15s'**
  String get add15s;

  /// No description provided for @browseExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Browse exercises and tap \"Add to plan\" to add here.'**
  String get browseExercisesHint;

  /// No description provided for @dietTracker.
  ///
  /// In en, this message translates to:
  /// **'Diet Tracker'**
  String get dietTracker;

  /// No description provided for @dietTrackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log meals and track your nutrition.'**
  String get dietTrackerSubtitle;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @addToBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Add to Breakfast'**
  String get addToBreakfast;

  /// No description provided for @addToLunch.
  ///
  /// In en, this message translates to:
  /// **'Add to Lunch'**
  String get addToLunch;

  /// No description provided for @addToDinner.
  ///
  /// In en, this message translates to:
  /// **'Add to Dinner'**
  String get addToDinner;

  /// No description provided for @addToSnack.
  ///
  /// In en, this message translates to:
  /// **'Add to Snack'**
  String get addToSnack;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addRecord;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @dietPlans.
  ///
  /// In en, this message translates to:
  /// **'Diet Plans'**
  String get dietPlans;

  /// No description provided for @newDietPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newDietPlan;

  /// No description provided for @targetCalories.
  ///
  /// In en, this message translates to:
  /// **'Target calories'**
  String get targetCalories;

  /// No description provided for @targetProtein.
  ///
  /// In en, this message translates to:
  /// **'Target protein'**
  String get targetProtein;

  /// No description provided for @targetCarbs.
  ///
  /// In en, this message translates to:
  /// **'Target carbs'**
  String get targetCarbs;

  /// No description provided for @targetFat.
  ///
  /// In en, this message translates to:
  /// **'Target fat'**
  String get targetFat;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @noDietPlans.
  ///
  /// In en, this message translates to:
  /// **'No diet plans yet'**
  String get noDietPlans;

  /// No description provided for @noDietPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a plan to set your daily nutrition targets.'**
  String get noDietPlansSubtitle;

  /// No description provided for @bodyData.
  ///
  /// In en, this message translates to:
  /// **'Body Data'**
  String get bodyData;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurements;

  /// No description provided for @noMeasurementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first measurement to start tracking progress.'**
  String get noMeasurementsSubtitle;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get waist;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest (cm)'**
  String get chest;

  /// No description provided for @hip.
  ///
  /// In en, this message translates to:
  /// **'Hip (cm)'**
  String get hip;

  /// No description provided for @arm.
  ///
  /// In en, this message translates to:
  /// **'Arm (cm)'**
  String get arm;

  /// No description provided for @thigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh (cm)'**
  String get thigh;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @noProgressData.
  ///
  /// In en, this message translates to:
  /// **'No progress data yet'**
  String get noProgressData;

  /// No description provided for @noProgressDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add body measurements to see your trends here.'**
  String get noProgressDataSubtitle;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get weightTrend;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to show trend'**
  String get notEnoughData;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @databaseInfo.
  ///
  /// In en, this message translates to:
  /// **'Database info'**
  String get databaseInfo;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get openSource;

  /// No description provided for @exerciseDataGifs.
  ///
  /// In en, this message translates to:
  /// **'Exercise data & GIFs'**
  String get exerciseDataGifs;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @glassShowcase.
  ///
  /// In en, this message translates to:
  /// **'Glass Showcase'**
  String get glassShowcase;

  /// No description provided for @glassShowcaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the Liquid Glass component gallery.'**
  String get glassShowcaseSubtitle;

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// No description provided for @healthToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get healthToday;

  /// No description provided for @healthSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get healthSteps;

  /// No description provided for @healthActiveEnergy.
  ///
  /// In en, this message translates to:
  /// **'Active Energy'**
  String get healthActiveEnergy;

  /// No description provided for @healthHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get healthHeartRate;

  /// No description provided for @healthDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get healthDistance;

  /// No description provided for @healthFlightsClimbed.
  ///
  /// In en, this message translates to:
  /// **'Flights Climbed'**
  String get healthFlightsClimbed;

  /// No description provided for @healthConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Apple Health'**
  String get healthConnectTitle;

  /// No description provided for @healthConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Authorize access to your health data to see steps, heart rate, calories, and more.'**
  String get healthConnectSubtitle;

  /// No description provided for @healthConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get healthConnect;

  /// No description provided for @healthSources.
  ///
  /// In en, this message translates to:
  /// **'Data Sources'**
  String get healthSources;

  /// No description provided for @healthSourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data is read from Apple Health on iOS. On other platforms, mock data is shown for demonstration.'**
  String get healthSourcesSubtitle;

  /// No description provided for @watchTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch'**
  String get watchTitle;

  /// No description provided for @watchConnected.
  ///
  /// In en, this message translates to:
  /// **'Watch Connected'**
  String get watchConnected;

  /// No description provided for @watchReachable.
  ///
  /// In en, this message translates to:
  /// **'Watch is reachable'**
  String get watchReachable;

  /// No description provided for @watchNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Watch Not Connected'**
  String get watchNotConnected;

  /// No description provided for @watchNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch is not available on this platform.'**
  String get watchNotAvailable;

  /// No description provided for @watchNotPaired.
  ///
  /// In en, this message translates to:
  /// **'No Apple Watch is paired. Pair your watch in the Watch app.'**
  String get watchNotPaired;

  /// No description provided for @watchWorkoutSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Workout Snapshot'**
  String get watchWorkoutSnapshot;

  /// No description provided for @watchHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get watchHeartRate;

  /// No description provided for @watchCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get watchCalories;

  /// No description provided for @watchProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get watchProgress;

  /// No description provided for @watchSets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get watchSets;

  /// No description provided for @watchElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get watchElapsed;

  /// No description provided for @watchStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get watchStartWorkout;

  /// No description provided for @watchStopWorkout.
  ///
  /// In en, this message translates to:
  /// **'Stop Workout'**
  String get watchStopWorkout;

  /// No description provided for @watchPing.
  ///
  /// In en, this message translates to:
  /// **'Ping Watch'**
  String get watchPing;

  /// No description provided for @watchDemoNote.
  ///
  /// In en, this message translates to:
  /// **'On non-iOS platforms, mock data is shown for demonstration.'**
  String get watchDemoNote;

  /// No description provided for @aiTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'AI Training Plan'**
  String get aiTrainingPlan;

  /// No description provided for @aiDietPlan.
  ///
  /// In en, this message translates to:
  /// **'AI Diet Plan'**
  String get aiDietPlan;

  /// No description provided for @aiGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get aiGender;

  /// No description provided for @aiAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get aiAge;

  /// No description provided for @aiHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get aiHeight;

  /// No description provided for @aiWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get aiWeight;

  /// No description provided for @aiExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get aiExperience;

  /// No description provided for @aiGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get aiGoal;

  /// No description provided for @aiDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Days/Week'**
  String get aiDaysPerWeek;

  /// No description provided for @aiSessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get aiSessionDuration;

  /// No description provided for @aiEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get aiEquipment;

  /// No description provided for @aiActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get aiActivityLevel;

  /// No description provided for @aiGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiGenerate;

  /// No description provided for @aiGenerating.
  ///
  /// In en, this message translates to:
  /// **'AI is generating your plan...'**
  String get aiGenerating;

  /// No description provided for @aiPlanPreview.
  ///
  /// In en, this message translates to:
  /// **'Plan Preview'**
  String get aiPlanPreview;

  /// No description provided for @aiMealSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Meal Suggestions'**
  String get aiMealSuggestions;

  /// No description provided for @aiRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get aiRegenerate;

  /// No description provided for @aiReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get aiReset;

  /// No description provided for @aiTargetCalories.
  ///
  /// In en, this message translates to:
  /// **'Target Calories'**
  String get aiTargetCalories;

  /// No description provided for @aiTargetProtein.
  ///
  /// In en, this message translates to:
  /// **'Target Protein'**
  String get aiTargetProtein;

  /// No description provided for @aiTargetCarbs.
  ///
  /// In en, this message translates to:
  /// **'Target Carbs'**
  String get aiTargetCarbs;

  /// No description provided for @aiTargetFat.
  ///
  /// In en, this message translates to:
  /// **'Target Fat'**
  String get aiTargetFat;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get subscriptionAvailable;

  /// No description provided for @subscriptionPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get subscriptionPurchase;

  /// No description provided for @subscriptionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subscriptionRestore;

  /// No description provided for @subscriptionCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get subscriptionCurrent;

  /// No description provided for @subscriptionFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get subscriptionFeatures;

  /// No description provided for @subscriptionFeatureExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get subscriptionFeatureExerciseLibrary;

  /// No description provided for @subscriptionFeatureTrainingPlans.
  ///
  /// In en, this message translates to:
  /// **'Training Plans'**
  String get subscriptionFeatureTrainingPlans;

  /// No description provided for @subscriptionFeatureAiTraining.
  ///
  /// In en, this message translates to:
  /// **'AI Training Plans'**
  String get subscriptionFeatureAiTraining;

  /// No description provided for @subscriptionFeatureAiDiet.
  ///
  /// In en, this message translates to:
  /// **'AI Diet Plans'**
  String get subscriptionFeatureAiDiet;

  /// No description provided for @subscriptionFeatureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get subscriptionFeatureAnalytics;

  /// No description provided for @subscriptionFeatureWatch.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch Features'**
  String get subscriptionFeatureWatch;

  /// No description provided for @subscriptionFeatureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get subscriptionFeatureCloudSync;

  /// No description provided for @subscriptionFeaturePriorityAi.
  ///
  /// In en, this message translates to:
  /// **'Priority AI'**
  String get subscriptionFeaturePriorityAi;

  /// No description provided for @dashboardTodayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get dashboardTodayWorkout;

  /// No description provided for @dashboardNoWorkout.
  ///
  /// In en, this message translates to:
  /// **'No workout scheduled. Tap to plan.'**
  String get dashboardNoWorkout;

  /// No description provided for @dashboardNoWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'No Workout Today'**
  String get dashboardNoWorkoutToday;

  /// No description provided for @dashboardScheduleWorkout.
  ///
  /// In en, this message translates to:
  /// **'Schedule a workout'**
  String get dashboardScheduleWorkout;

  /// No description provided for @dashboardRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get dashboardRestDay;

  /// No description provided for @dashboardEnjoyRest.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your recovery'**
  String get dashboardEnjoyRest;

  /// No description provided for @dashboardStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dashboardStartWorkout;

  /// No description provided for @dashboardQuickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get dashboardQuickStats;

  /// No description provided for @dashboardWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get dashboardWorkouts;

  /// No description provided for @dashboardVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get dashboardVolume;

  /// No description provided for @dashboardWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get dashboardWeight;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get dashboardNoData;

  /// No description provided for @dashboardAIPlans.
  ///
  /// In en, this message translates to:
  /// **'AI Plans'**
  String get dashboardAIPlans;

  /// No description provided for @dashboardAISubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate personalized plans with AI'**
  String get dashboardAISubtitle;

  /// No description provided for @dashboardSubscription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get dashboardSubscription;

  /// No description provided for @dashboardSubscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI, analytics, and more'**
  String get dashboardSubscriptionSubtitle;

  /// No description provided for @gymVisualCopyright.
  ///
  /// In en, this message translates to:
  /// **'© Gym visual — gymvisual.com'**
  String get gymVisualCopyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
