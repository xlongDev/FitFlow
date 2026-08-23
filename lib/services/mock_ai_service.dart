
import '../models/ai_model.dart';
import '../utils/app_logger.dart';
import 'ai_service.dart';

/// A [AIService] that generates plans using rule-based logic.
///
/// Used when:
///   * No AI API key is configured.
///   * Running tests.
///   * The user is offline.
///
/// The mock generates realistic plans based on the user's input (goal,
/// experience, days per week, equipment). It's not as sophisticated as a
/// real AI, but it produces structured, usable plans that the user can
/// preview and save.
class MockAIService implements AIService {
  MockAIService();

  @override
  Future<AITrainingPlanResult> generateTrainingPlan(
    AITrainingPlanRequest request,
  ) async {
    // Simulate AI processing delay.
    await Future<void>.delayed(const Duration(seconds: 2));

    AppLogger.i('MockAIService: generating training plan for '
        '${request.gender}, ${request.experience}, ${request.goal}');

    final planName = _planNameFor(request.goal, request.experience);
    final description = _descriptionFor(request.goal, request.experience);
    final days = _generateDays(request);

    return AITrainingPlanResult(
      planName: planName,
      description: description,
      goal: request.goal,
      daysPerWeek: request.daysPerWeek,
      days: days,
    );
  }

  @override
  Future<AIDietPlanResult> generateDietPlan(
    AIDietPlanRequest request,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    AppLogger.i('MockAIService: generating diet plan for '
        '${request.gender}, ${request.goal}');

    // Calculate BMR (Mifflin-St Jeor equation).
    final bmr = _calculateBMR(request);
    final tdee = _calculateTDEE(bmr, request.activityLevel);

    // Adjust calories based on goal.
    double targetCalories;
    switch (request.goal) {
      case '增肌':
        targetCalories = tdee + 300;
      case '减脂':
        targetCalories = tdee - 400;
      default:
        targetCalories = tdee;
    }

    // Macro split: 30% protein, 45% carbs, 25% fat.
    final protein = (targetCalories * 0.30 / 4).round().toDouble();
    final carbs = (targetCalories * 0.45 / 4).round().toDouble();
    final fat = (targetCalories * 0.25 / 9).round().toDouble();

    final meals = _generateMeals(targetCalories, protein, carbs, fat);

    return AIDietPlanResult(
      planName: '${request.goal}饮食计划',
      goal: request.goal,
      targetCalories: targetCalories.roundToDouble(),
      targetProtein: protein,
      targetCarbs: carbs,
      targetFat: fat,
      meals: meals,
    );
  }

  // ---------------------------------------------------------------------------
  // Training plan generation
  // ---------------------------------------------------------------------------

  String _planNameFor(String goal, String experience) {
    final exp = experience == 'beginner'
        ? '新手'
        : experience == 'advanced'
            ? '进阶'
            : '中级';
    return '$exp$goal计划';
  }

  String _descriptionFor(String goal, String experience) {
    return '基于您的${experience == 'beginner' ? '新手' : '有经验'}水平和'
        '$goal目标，AI为您生成了个性化训练计划。'
        '请根据自身情况调整重量和组数。';
  }

  List<AITrainingDay> _generateDays(AITrainingPlanRequest request) {
    final days = <AITrainingDay>[];
    final isBeginner = request.experience == 'beginner';
    final baseSets = isBeginner ? 3 : 4;
    final baseReps = request.goal == '力量提升' ? '3-5' : '8-12';
    final restSeconds = request.goal == '力量提升' ? 180 : 90;

    switch (request.daysPerWeek) {
      case 3:
        days.addAll([
          _pushDay(baseSets, baseReps, restSeconds),
          _pullDay(baseSets, baseReps, restSeconds),
          _legDay(baseSets, baseReps, restSeconds),
        ]);
      case 4:
        days.addAll([
          _pushDay(baseSets, baseReps, restSeconds),
          _pullDay(baseSets, baseReps, restSeconds),
          _legDay(baseSets, baseReps, restSeconds),
          _upperBodyDay(baseSets, baseReps, restSeconds),
        ]);
      default:
        days.addAll([
          _pushDay(baseSets, baseReps, restSeconds),
          _pullDay(baseSets, baseReps, restSeconds),
          _legDay(baseSets, baseReps, restSeconds),
          _upperBodyDay(baseSets, baseReps, restSeconds),
          _fullBodyDay(baseSets, baseReps, restSeconds),
        ]);
    }

    return days;
  }

  AITrainingDay _pushDay(int sets, String reps, int rest) {
    return AITrainingDay(
      name: '推日（胸+肩+三头）',
      exercises: [
        AITrainingExercise(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0050', exerciseName: 'Incline Dumbbell Press', sets: sets, reps: '10-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0250', exerciseName: 'Tricep Pushdown', sets: sets, reps: '12-15', restSeconds: 60),
      ],
    );
  }

  AITrainingDay _pullDay(int sets, String reps, int rest) {
    return AITrainingDay(
      name: '拉日（背+二头）',
      exercises: [
        AITrainingExercise(exerciseId: '0100', exerciseName: 'Barbell Row', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0150', exerciseName: 'Lat Pulldown', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0115', exerciseName: 'Seated Cable Row', sets: sets, reps: '10-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0230', exerciseName: 'Dumbbell Bicep Curl', sets: sets, reps: '12-15', restSeconds: 60),
      ],
    );
  }

  AITrainingDay _legDay(int sets, String reps, int rest) {
    return AITrainingDay(
      name: '腿日（股四头+腘绳肌+小腿）',
      exercises: [
        AITrainingExercise(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0154', exerciseName: 'Romanian Deadlift', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0135', exerciseName: 'Leg Press', sets: sets, reps: '12-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0145', exerciseName: 'Calf Raise', sets: sets, reps: '15-20', restSeconds: 45),
      ],
    );
  }

  AITrainingDay _upperBodyDay(int sets, String reps, int rest) {
    return AITrainingDay(
      name: '上肢日',
      exercises: [
        AITrainingExercise(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0100', exerciseName: 'Barbell Row', sets: sets, reps: reps, restSeconds: rest),
        AITrainingExercise(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', sets: sets, reps: '10-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0230', exerciseName: 'Dumbbell Bicep Curl', sets: sets, reps: '12-15', restSeconds: 60),
      ],
    );
  }

  AITrainingDay _fullBodyDay(int sets, String reps, int rest) {
    return AITrainingDay(
      name: '全身日',
      exercises: [
        AITrainingExercise(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: sets, reps: '12-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: sets, reps: '12-15', restSeconds: 60),
        AITrainingExercise(exerciseId: '0100', exerciseName: 'Barbell Row', sets: sets, reps: '12-15', restSeconds: 60),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Diet plan generation
  // ---------------------------------------------------------------------------

  double _calculateBMR(AIDietPlanRequest request) {
    // Mifflin-St Jeor equation.
    if (request.gender == 'male') {
      return 10 * request.weight + 6.25 * request.height - 5 * request.age + 5;
    } else {
      return 10 * request.weight + 6.25 * request.height - 5 * request.age - 161;
    }
  }

  double _calculateTDEE(double bmr, String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return bmr * 1.2;
      case 'light':
        return bmr * 1.375;
      case 'moderate':
        return bmr * 1.55;
      case 'active':
        return bmr * 1.725;
      default:
        return bmr * 1.55;
    }
  }

  List<AIMealSuggestion> _generateMeals(
    double calories,
    double protein,
    double carbs,
    double fat,
  ) {
    return [
      AIMealSuggestion(
        mealType: 'breakfast',
        foodName: '燕麦粥 + 鸡蛋 + 香蕉',
        calories: calories * 0.25,
        protein: protein * 0.25,
        carbs: carbs * 0.30,
        fat: fat * 0.20,
      ),
      AIMealSuggestion(
        mealType: 'lunch',
        foodName: '鸡胸肉 + 糙米饭 + 蔬菜',
        calories: calories * 0.35,
        protein: protein * 0.35,
        carbs: carbs * 0.35,
        fat: fat * 0.35,
      ),
      AIMealSuggestion(
        mealType: 'snack',
        foodName: '蛋白粉 + 坚果',
        calories: calories * 0.15,
        protein: protein * 0.20,
        carbs: carbs * 0.10,
        fat: fat * 0.15,
      ),
      AIMealSuggestion(
        mealType: 'dinner',
        foodName: '三文鱼 + 红薯 + 沙拉',
        calories: calories * 0.25,
        protein: protein * 0.20,
        carbs: carbs * 0.25,
        fat: fat * 0.30,
      ),
    ];
  }
}
