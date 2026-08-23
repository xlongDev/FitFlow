import '../../models/training_plan_model.dart';
import '../../utils/app_logger.dart';

/// A template for a default training plan.
///
/// Describes a plan's metadata + its days + the exercises in each day.
/// The [DefaultPlansService] uses these templates to create real
/// [TrainingPlanModel]s in the database on first launch.
class PlanTemplate {
  const PlanTemplate({
    required this.name,
    required this.description,
    required this.goal,
    required this.daysPerWeek,
    required this.days,
  });

  final String name;
  final String description;
  final String goal;
  final int daysPerWeek;
  final List<DayTemplate> days;
}

/// A template for a training day within a plan.
class DayTemplate {
  const DayTemplate({
    required this.name,
    required this.exercises,
  });

  final String name;
  final List<ExerciseTemplate> exercises;
}

/// A template for an exercise within a day.
class ExerciseTemplate {
  const ExerciseTemplate({
    required this.exerciseId,
    required this.exerciseName,
    this.sets = 3,
    this.reps = '8-12',
    this.weight = 0,
    this.restSeconds = 90,
    this.notes = '',
  });

  final String exerciseId;
  final String exerciseName;
  final int sets;
  final String reps;
  final double weight;
  final int restSeconds;
  final String notes;
}

/// Provides built-in default training plan templates.
///
/// These templates are used on first launch to populate the user's plan
/// library so they can start training immediately without creating plans
/// from scratch. The templates cover common goals (增肌 / 减脂 / 塑形) and
/// experience levels (新手 / 进阶).
///
/// Each template references exercises from the bundled exercise library by
/// id. The exercise ids are the zero-padded 4-digit strings from
/// `exercises.json`.
class DefaultPlansService {
  DefaultPlansService._();

  /// Returns all default plan templates.
  ///
  /// The templates are ordered by: beginner first, then intermediate.
  /// Within each level, plans are ordered: 增肌 → 减脂 → 塑形.
  static List<PlanTemplate> get all => [
        // --- Beginner plans ---
        _beginnerMuscleGain,
        _beginnerFatLoss,
        _beginnerToning,
        // --- Intermediate plans ---
        _intermediateMuscleGain,
        _intermediateFatLoss,
        _intermediateToning,
      ];

  // ===========================================================================
  // Beginner plans
  // ===========================================================================

  static const _beginnerMuscleGain = PlanTemplate(
    name: '新手增肌',
    description: '适合刚开始力量训练的新手，每周 3 天，全身复合动作，注重基础力量建立。',
    goal: '增肌',
    daysPerWeek: 3,
    days: [
      DayTemplate(
        name: 'Day A — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', reps: '8-10'),
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', reps: '8-10'),
          ExerciseTemplate(exerciseId: '0153', exerciseName: 'Barbell Deadlift', reps: '8-10'),
          ExerciseTemplate(exerciseId: '0098', exerciseName: 'Pull Up', reps: '6-10'),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', reps: '10-12'),
        ],
      ),
      DayTemplate(
        name: 'Day B — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press'),
          ExerciseTemplate(exerciseId: '0130', exerciseName: 'Front Squat', reps: '8-10'),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', reps: '10-12'),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row'),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', reps: '10-12'),
        ],
      ),
      DayTemplate(
        name: 'Day C — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0050', exerciseName: 'Dumbbell Fly', reps: '10-15'),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', reps: '10-12'),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', reps: '10-12'),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', reps: '12-15'),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', reps: '10-15'),
        ],
      ),
    ],
  );

  static const _beginnerFatLoss = PlanTemplate(
    name: '新手减脂',
    description: '适合需要减脂的新手，每周 4 天，高强度复合动作 + 短休息时间，提升代谢。',
    goal: '减脂',
    daysPerWeek: 4,
    days: [
      DayTemplate(
        name: 'Day A — 上肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', reps: '15', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day B — 下肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', reps: '15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0153', exerciseName: 'Barbell Deadlift', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0140', exerciseName: 'Leg Curl', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', reps: '20', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day C — 上肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0035', exerciseName: 'Hammer Curl', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0042', exerciseName: 'Overhead Tricep Extension', reps: '15', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day D — 下肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0130', exerciseName: 'Front Squat', sets: 4, reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0138', exerciseName: 'Walking Lunge', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0141', exerciseName: 'Leg Extension', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', reps: '20', restSeconds: 45),
        ],
      ),
    ],
  );

  static const _beginnerToning = PlanTemplate(
    name: '新手塑形',
    description: '适合想要塑形的新手，每周 3 天，全身均衡训练，中等重量高次数。',
    goal: '塑形',
    daysPerWeek: 3,
    days: [
      DayTemplate(
        name: 'Day A — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', reps: '15', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day B — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', reps: '20', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day C — 全身',
        exercises: [
          ExerciseTemplate(exerciseId: '0050', exerciseName: 'Dumbbell Fly', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0153', exerciseName: 'Barbell Deadlift', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0098', exerciseName: 'Pull Up', reps: '6-10', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0042', exerciseName: 'Overhead Tricep Extension', reps: '15', restSeconds: 45),
        ],
      ),
    ],
  );

  // ===========================================================================
  // Intermediate plans
  // ===========================================================================

  static const _intermediateMuscleGain = PlanTemplate(
    name: '进阶增肌 — Push Pull Legs',
    description: '适合有训练经验的用户，每周 6 天 Push/Pull/Legs 分化训练，大容量增肌。',
    goal: '增肌',
    daysPerWeek: 6,
    days: [
      DayTemplate(
        name: 'Push — 胸/肩/三头',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: 4, reps: '6-8'),
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press', sets: 4),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', sets: 4),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', sets: 4, reps: '10-15'),
          ExerciseTemplate(exerciseId: '0042', exerciseName: 'Overhead Tricep Extension', reps: '10-15'),
        ],
      ),
      DayTemplate(
        name: 'Pull — 背/二头',
        exercises: [
          ExerciseTemplate(exerciseId: '0153', exerciseName: 'Barbell Deadlift', sets: 4, reps: '6-8'),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', sets: 4),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0098', exerciseName: 'Pull Up', sets: 4, reps: '6-10'),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0035', exerciseName: 'Hammer Curl', reps: '10-15'),
        ],
      ),
      DayTemplate(
        name: 'Legs — 股四头/臀/腿后',
        exercises: [
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: 4, reps: '6-8'),
          ExerciseTemplate(exerciseId: '0130', exerciseName: 'Front Squat', sets: 4),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', sets: 4),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', sets: 4, reps: '10-15'),
          ExerciseTemplate(exerciseId: '0140', exerciseName: 'Leg Curl', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', sets: 4, reps: '15-20'),
        ],
      ),
      DayTemplate(
        name: 'Push — 胸/肩/三头',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: 4, reps: '8-10'),
          ExerciseTemplate(exerciseId: '0050', exerciseName: 'Dumbbell Fly', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0202', exerciseName: 'Arnold Press', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0204', exerciseName: 'Front Raise', reps: '12-15'),
          ExerciseTemplate(exerciseId: '0041', exerciseName: 'Skull Crusher', sets: 4, reps: '10-15'),
          ExerciseTemplate(exerciseId: '0043', exerciseName: 'Dips'),
        ],
      ),
      DayTemplate(
        name: 'Pull — 背/二头',
        exercises: [
          ExerciseTemplate(exerciseId: '0101', exerciseName: 'Seated Cable Row', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0156', exerciseName: 'T-Bar Row', sets: 4),
          ExerciseTemplate(exerciseId: '0157', exerciseName: 'Face Pull', reps: '15-20'),
          ExerciseTemplate(exerciseId: '0031', exerciseName: 'Preacher Curl', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0036', exerciseName: 'Cable Curl', reps: '12-15'),
        ],
      ),
      DayTemplate(
        name: 'Legs — 股四头/臀/腿后',
        exercises: [
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: 4, reps: '8-10'),
          ExerciseTemplate(exerciseId: '0138', exerciseName: 'Walking Lunge', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', sets: 4, reps: '10-12'),
          ExerciseTemplate(exerciseId: '0141', exerciseName: 'Leg Extension', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0140', exerciseName: 'Leg Curl', sets: 4, reps: '12-15'),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', sets: 4, reps: '15-20'),
        ],
      ),
    ],
  );

  static const _intermediateFatLoss = PlanTemplate(
    name: '进阶减脂 — Upper/Lower',
    description: '适合有训练经验的用户，每周 4 天上下肢分化，高次数短休息，最大化燃脂。',
    goal: '减脂',
    daysPerWeek: 4,
    days: [
      DayTemplate(
        name: 'Upper A — 上肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', reps: '15', restSeconds: 30),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', reps: '15', restSeconds: 30),
        ],
      ),
      DayTemplate(
        name: 'Lower A — 下肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', sets: 4, reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0140', exerciseName: 'Leg Curl', reps: '15', restSeconds: 30),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', reps: '20', restSeconds: 30),
        ],
      ),
      DayTemplate(
        name: 'Upper B — 上肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0101', exerciseName: 'Seated Cable Row', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', sets: 4, reps: '15', restSeconds: 30),
          ExerciseTemplate(exerciseId: '0098', exerciseName: 'Pull Up', sets: 4, restSeconds: 45),
          ExerciseTemplate(exerciseId: '0035', exerciseName: 'Hammer Curl', reps: '15', restSeconds: 30),
          ExerciseTemplate(exerciseId: '0042', exerciseName: 'Overhead Tricep Extension', reps: '15', restSeconds: 30),
        ],
      ),
      DayTemplate(
        name: 'Lower B — 下肢',
        exercises: [
          ExerciseTemplate(exerciseId: '0130', exerciseName: 'Front Squat', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0138', exerciseName: 'Walking Lunge', sets: 4, reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0141', exerciseName: 'Leg Extension', reps: '15', restSeconds: 30),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', reps: '20', restSeconds: 30),
        ],
      ),
    ],
  );

  static const _intermediateToning = PlanTemplate(
    name: '进阶塑形 — 全身',
    description: '适合有训练经验的用户，每周 5 天全身分化，均衡发展，线条雕刻。',
    goal: '塑形',
    daysPerWeek: 5,
    days: [
      DayTemplate(
        name: 'Day 1 — 胸/三头',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0049', exerciseName: 'Incline Dumbbell Press', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0050', exerciseName: 'Dumbbell Fly', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0040', exerciseName: 'Tricep Pushdown', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0042', exerciseName: 'Overhead Tricep Extension', reps: '12-15', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day 2 — 背/二头',
        exercises: [
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0155', exerciseName: 'Lat Pulldown', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0098', exerciseName: 'Pull Up', sets: 4, restSeconds: 60),
          ExerciseTemplate(exerciseId: '0030', exerciseName: 'Dumbbell Bicep Curl', sets: 4, reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0035', exerciseName: 'Hammer Curl', reps: '12-15', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day 3 — 肩/核心',
        exercises: [
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0203', exerciseName: 'Lateral Raise', sets: 4, reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0204', exerciseName: 'Front Raise', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0157', exerciseName: 'Face Pull', reps: '15-20', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day 4 — 腿/臀',
        exercises: [
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0154', exerciseName: 'Romanian Deadlift', sets: 4, reps: '10-12', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0135', exerciseName: 'Leg Press', reps: '12-15', restSeconds: 60),
          ExerciseTemplate(exerciseId: '0140', exerciseName: 'Leg Curl', reps: '15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0145', exerciseName: 'Calf Raise', sets: 4, reps: '15-20', restSeconds: 45),
        ],
      ),
      DayTemplate(
        name: 'Day 5 — 全身循环',
        exercises: [
          ExerciseTemplate(exerciseId: '0048', exerciseName: 'Barbell Bench Press', reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0125', exerciseName: 'Barbell Squat', reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0100', exerciseName: 'Barbell Row', reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0201', exerciseName: 'Dumbbell Shoulder Press', reps: '12-15', restSeconds: 45),
          ExerciseTemplate(exerciseId: '0153', exerciseName: 'Barbell Deadlift', reps: '12-15', restSeconds: 45),
        ],
      ),
    ],
  );

  /// Logs the template count for debugging.
  static void logSummary() {
    AppLogger.i('DefaultPlansService: ${all.length} templates available');
    for (final t in all) {
      AppLogger.d('  - ${t.name} (${t.daysPerWeek} days, ${t.days.length} sessions)');
    }
  }
}
