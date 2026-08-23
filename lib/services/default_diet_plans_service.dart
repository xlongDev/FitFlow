
/// A template for a default diet plan.
class DietPlanTemplate {
  const DietPlanTemplate({
    required this.name,
    required this.goal,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  final String name;
  final String goal;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
}

/// Provides built-in default diet plan templates.
///
/// These templates give the user a starting point for their daily nutrition
/// targets. The values are based on common recommendations for an average
/// adult (70kg); the user should adjust them based on their actual body
/// weight and goals.
class DefaultDietPlansService {
  DefaultDietPlansService._();

  static List<DietPlanTemplate> get all => [
        const DietPlanTemplate(
          name: '增肌饮食',
          goal: '增肌',
          targetCalories: 2800,
          targetProtein: 175,
          targetCarbs: 350,
          targetFat: 90,
        ),
        const DietPlanTemplate(
          name: '减脂饮食',
          goal: '减脂',
          targetCalories: 1800,
          targetProtein: 150,
          targetCarbs: 180,
          targetFat: 60,
        ),
        const DietPlanTemplate(
          name: '塑形饮食',
          goal: '塑形',
          targetCalories: 2200,
          targetProtein: 165,
          targetCarbs: 250,
          targetFat: 70,
        ),
        const DietPlanTemplate(
          name: '维持饮食',
          goal: '维持',
          targetCalories: 2300,
          targetProtein: 140,
          targetCarbs: 280,
          targetFat: 75,
        ),
      ];
}
