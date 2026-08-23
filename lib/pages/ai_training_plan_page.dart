import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/ai_model.dart';
import '../../providers/ai_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// AI training plan generation page.
///
/// The user fills in their profile (gender, age, height, weight, experience,
/// goal, days per week, equipment) and taps "Generate". The AI generates a
/// personalized training plan which is displayed for preview. The user can
/// then save it to their plan library.
class AITrainingPlanPage extends ConsumerStatefulWidget {
  const AITrainingPlanPage({super.key});

  @override
  ConsumerState<AITrainingPlanPage> createState() => _AITrainingPlanPageState();
}

class _AITrainingPlanPageState extends ConsumerState<AITrainingPlanPage> {
  String _gender = 'male';
  int _age = 25;
  int _height = 170;
  double _weight = 70;
  String _experience = 'beginner';
  String _goal = '增肌';
  int _daysPerWeek = 3;
  int _sessionDuration = 60;
  String _equipment = 'full gym';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiTrainingPlanProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.aiTrainingPlan)),
      body: switch (state) {
        AITrainingPlanIdle() => _InputForm(
            l: l,
            gender: _gender,
            age: _age,
            height: _height,
            weight: _weight,
            experience: _experience,
            goal: _goal,
            daysPerWeek: _daysPerWeek,
            sessionDuration: _sessionDuration,
            equipment: _equipment,
            onGenderChanged: (v) => setState(() => _gender = v),
            onAgeChanged: (v) => setState(() => _age = v),
            onHeightChanged: (v) => setState(() => _height = v),
            onWeightChanged: (v) => setState(() => _weight = v),
            onExperienceChanged: (v) => setState(() => _experience = v),
            onGoalChanged: (v) => setState(() => _goal = v),
            onDaysChanged: (v) => setState(() => _daysPerWeek = v),
            onDurationChanged: (v) => setState(() => _sessionDuration = v),
            onEquipmentChanged: (v) => setState(() => _equipment = v),
            onGenerate: _generate,
          ),
        AITrainingPlanGenerating() => _GeneratingState(l: l),
        AITrainingPlanGenerated(:final result) => _ResultPreview(
            l: l,
            result: result,
            onRegenerate: _generate,
            onReset: () => ref.read(aiTrainingPlanProvider.notifier).reset(),
          ),
        AITrainingPlanError(:final message) => ErrorState(
            message: message,
            onRetry: _generate,
          ),
      },
    );
  }

  Future<void> _generate() async {
    final request = AITrainingPlanRequest(
      gender: _gender,
      age: _age,
      height: _height,
      weight: _weight,
      experience: _experience,
      goal: _goal,
      daysPerWeek: _daysPerWeek,
      sessionDuration: _sessionDuration,
      equipment: _equipment,
    );
    await ref.read(aiTrainingPlanProvider.notifier).generate(request);
  }
}

/// The input form shown in idle state.
class _InputForm extends StatelessWidget {
  const _InputForm({
    required this.l,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.experience,
    required this.goal,
    required this.daysPerWeek,
    required this.sessionDuration,
    required this.equipment,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
    required this.onExperienceChanged,
    required this.onGoalChanged,
    required this.onDaysChanged,
    required this.onDurationChanged,
    required this.onEquipmentChanged,
    required this.onGenerate,
  });

  final AppLocalizations l;
  final String gender;
  final int age;
  final int height;
  final double weight;
  final String experience;
  final String goal;
  final int daysPerWeek;
  final int sessionDuration;
  final String equipment;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<int> onHeightChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<String> onEquipmentChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _DropdownField(
          label: l.aiGender,
          value: gender,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
          ],
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _NumberField(
          label: l.aiAge,
          value: age,
          onChanged: onAgeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _NumberField(
          label: l.aiHeight,
          value: height,
          onChanged: onHeightChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _NumberField(
          label: l.aiWeight,
          value: weight.round(),
          onChanged: (v) => onWeightChanged(v.toDouble()),
        ),
        const SizedBox(height: AppSpacing.md),
        _DropdownField(
          label: l.aiExperience,
          value: experience,
          items: const [
            DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
            DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
          ],
          onChanged: onExperienceChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _DropdownField(
          label: l.aiGoal,
          value: goal,
          items: const [
            DropdownMenuItem(value: '增肌', child: Text('增肌')),
            DropdownMenuItem(value: '减脂', child: Text('减脂')),
            DropdownMenuItem(value: '塑形', child: Text('塑形')),
            DropdownMenuItem(value: '力量提升', child: Text('力量提升')),
          ],
          onChanged: onGoalChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _NumberField(
          label: l.aiDaysPerWeek,
          value: daysPerWeek,
          onChanged: onDaysChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _NumberField(
          label: l.aiSessionDuration,
          value: sessionDuration,
          onChanged: onDurationChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _DropdownField(
          label: l.aiEquipment,
          value: equipment,
          items: const [
            DropdownMenuItem(value: 'full gym', child: Text('Full Gym')),
            DropdownMenuItem(value: 'dumbbells only', child: Text('Dumbbells Only')),
            DropdownMenuItem(value: 'body weight', child: Text('Body Weight')),
          ],
          onChanged: onEquipmentChanged,
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassButton(
          label: l.aiGenerate,
          icon: Icons.auto_awesome,
          expanded: true,
          onPressed: onGenerate,
        ),
      ],
    );
  }
}

/// The generating state — shows a loading indicator.
class _GeneratingState extends StatelessWidget {
  const _GeneratingState({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.aiGenerating,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// The result preview — shows the generated plan.
class _ResultPreview extends StatelessWidget {
  const _ResultPreview({
    required this.l,
    required this.result,
    required this.onRegenerate,
    required this.onReset,
  });

  final AppLocalizations l;
  final AITrainingPlanResult result;
  final VoidCallback onRegenerate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // Plan header
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.planName, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(result.description, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  GlassChip(label: result.goal, selected: true),
                  GlassChip(label: '${result.daysPerWeek} ${l.aiDaysPerWeek}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Days
        Text(l.aiPlanPreview, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        for (final day in result.days) ...[
          GlassContainer(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                for (final ex in day.exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs3),
                    child: Text(
                      '• ${ex.exerciseName} — ${ex.sets}×${ex.reps}'
                      '${ex.restSeconds > 0 ? ' (${ex.restSeconds}s rest)' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: l.aiRegenerate,
                icon: Icons.refresh,
                style: GlassButtonStyle.secondary,
                onPressed: onRegenerate,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassButton(
                label: l.aiReset,
                style: GlassButtonStyle.text,
                onPressed: onReset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A dropdown field with a label.
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            items: items,
            onChanged: (v) => onChanged(v ?? value),
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}

/// A number input field with a label.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
