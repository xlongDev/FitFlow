import 'package:flutter/material.dart';

import '../../models/exercise_model.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// A card showing the exercise's metadata: body part, equipment, target
/// muscle, and secondary muscles.
///
/// Rendered as a 2x2 grid of labeled tiles inside a [GlassContainer].
class ExerciseMetadataCard extends StatelessWidget {
  const ExerciseMetadataCard({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryMuscles = exercise.secondaryMuscles;

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          // 2x2 grid of metadata tiles
          Row(
            children: [
              Expanded(
                child: _MetadataTile(
                  icon: Icons.accessibility_new,
                  label: 'Body Part',
                  value: _capitalize(exercise.bodyPart),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetadataTile(
                  icon: Icons.fitness_center,
                  label: 'Equipment',
                  value: _capitalize(exercise.equipment),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetadataTile(
                  icon: Icons.center_focus_strong,
                  label: 'Target',
                  value: _capitalize(exercise.target),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetadataTile(
                  icon: Icons.groups,
                  label: 'Muscle Group',
                  value: _capitalize(exercise.muscleGroup),
                ),
              ),
            ],
          ),
          // Secondary muscles (if any)
          if (secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Secondary muscles', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: secondaryMuscles.map((m) {
                return GlassChip(label: _capitalize(m));
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Capitalizes the first letter of [text] for display.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// A single metadata tile with an icon, label, and value.
class _MetadataTile extends StatelessWidget {
  const _MetadataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.5,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xs3),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
