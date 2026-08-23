import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/ai_model.dart';
import '../../providers/ai_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// AI diet plan generation page.
///
/// The user fills in their profile and dietary preferences, and the AI
/// generates a personalized diet plan with daily nutrition targets and
/// meal suggestions.
class AIDietPlanPage extends ConsumerStatefulWidget {
  const AIDietPlanPage({super.key});

  @override
  ConsumerState<AIDietPlanPage> createState() => _AIDietPlanPageState();
}

class _AIDietPlanPageState extends ConsumerState<AIDietPlanPage> {
  String _gender = 'male';
  int _age = 25;
  int _height = 170;
  double _weight = 70;
  String _goal = '增肌';
  String _activityLevel = 'moderate';
  int _trainingDaysPerWeek = 3;
  final String _dietaryPreference = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiDietPlanProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.aiDietPlan)),
      body: switch (state) {
        AIDietPlanIdle() => _buildInputForm(l),
        AIDietPlanGenerating() => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.lg),
                Text(l.aiGenerating, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        AIDietPlanGenerated(:final result) => _buildResult(l, result),
        AIDietPlanError(:final message) => ErrorState(
            message: message,
            onRetry: _generate,
          ),
      },
    );
  }

  Widget _buildInputForm(AppLocalizations l) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _buildDropdown(l.aiGender, _gender, ['male', 'female'], (v) => setState(() => _gender = v)),
        const SizedBox(height: AppSpacing.md),
        _buildNumberField(l.aiAge, _age, (v) => setState(() => _age = v)),
        const SizedBox(height: AppSpacing.md),
        _buildNumberField(l.aiHeight, _height, (v) => setState(() => _height = v)),
        const SizedBox(height: AppSpacing.md),
        _buildNumberField(l.aiWeight, _weight.round(), (v) => setState(() => _weight = v.toDouble())),
        const SizedBox(height: AppSpacing.md),
        _buildDropdown(l.aiGoal, _goal, ['增肌', '减脂', '塑形', '维持'], (v) => setState(() => _goal = v)),
        const SizedBox(height: AppSpacing.md),
        _buildDropdown(l.aiActivityLevel, _activityLevel, ['sedentary', 'light', 'moderate', 'active'], (v) => setState(() => _activityLevel = v)),
        const SizedBox(height: AppSpacing.md),
        _buildNumberField(l.aiDaysPerWeek, _trainingDaysPerWeek, (v) => setState(() => _trainingDaysPerWeek = v)),
        const SizedBox(height: AppSpacing.xl),
        GlassButton(
          label: l.aiGenerate,
          icon: Icons.auto_awesome,
          expanded: true,
          onPressed: _generate,
        ),
      ],
    );
  }

  Widget _buildResult(AppLocalizations l, AIDietPlanResult result) {
    final theme = Theme.of(context);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.planName, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              _NutritionRow(label: l.aiTargetCalories, value: '${result.targetCalories.toStringAsFixed(0)} kcal'),
              _NutritionRow(label: l.aiTargetProtein, value: '${result.targetProtein.toStringAsFixed(0)} g'),
              _NutritionRow(label: l.aiTargetCarbs, value: '${result.targetCarbs.toStringAsFixed(0)} g'),
              _NutritionRow(label: l.aiTargetFat, value: '${result.targetFat.toStringAsFixed(0)} g'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l.aiMealSuggestions, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        for (final meal in result.meals) ...[
          GlassContainer(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.foodName, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${meal.calories.toStringAsFixed(0)} kcal · '
                  'P${meal.protein.toStringAsFixed(0)} '
                  'C${meal.carbs.toStringAsFixed(0)} '
                  'F${meal.fat.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: l.aiRegenerate,
                icon: Icons.refresh,
                style: GlassButtonStyle.secondary,
                onPressed: _generate,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassButton(
                label: l.aiReset,
                style: GlassButtonStyle.text,
                onPressed: () => ref.read(aiDietPlanProvider.notifier).reset(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => onChanged(v ?? value),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, int value, ValueChanged<int> onChanged) {
    final controller = TextEditingController(text: value.toString());
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) onChanged(n);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _generate() async {
    final request = AIDietPlanRequest(
      gender: _gender,
      age: _age,
      height: _height,
      weight: _weight,
      goal: _goal,
      activityLevel: _activityLevel,
      trainingDaysPerWeek: _trainingDaysPerWeek,
      dietaryPreference: _dietaryPreference,
    );
    await ref.read(aiDietPlanProvider.notifier).generate(request);
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
