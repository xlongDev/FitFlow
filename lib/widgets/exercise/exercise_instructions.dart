import 'package:flutter/material.dart';

import '../../models/exercise_model.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Displays the exercise's instructions and step-by-step tutorial.
///
/// Shows the full instruction text for the current language, followed by
/// the numbered step list. Both come from the multilingual maps in
/// [ExerciseModel].
///
/// The language is currently hardcoded to 'en' — Phase 12 (Localization)
/// will wire this to the active locale.
class ExerciseInstructions extends StatelessWidget {
  const ExerciseInstructions({
    super.key,
    required this.exercise,
    this.languageCode = 'en',
  });

  final ExerciseModel exercise;

  /// ISO 639-1 language code (e.g. 'en', 'zh').
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instruction = exercise.instructions[languageCode] ??
        exercise.instructions['en'] ??
        'No instructions available.';
    final steps = exercise.instructionSteps[languageCode] ??
        exercise.instructionSteps['en'] ??
        <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text('How to perform', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),

        // Full instruction text
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Instructions',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                instruction,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),

        // Step-by-step tutorial
        if (steps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Step by step', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ..._buildSteps(steps, theme),
        ],
      ],
    );
  }

  /// Builds the numbered step cards.
  List<Widget> _buildSteps(List<String> steps, ThemeData theme) {
    final widgets = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i < steps.length - 1 ? AppSpacing.sm : 0,
          ),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    steps[i],
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
