import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/exercise_library_provider.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// A bottom sheet for selecting body-part and equipment filters.
///
/// Shows two sections of [GlassChip]s — one for body parts, one for
/// equipment. Chips toggle on / off. The current selection is read from
/// and written back to [ExerciseLibraryNotifier].
class ExerciseFilterSheet extends ConsumerWidget {
  const ExerciseFilterSheet({
    super.key,
    required this.bodyParts,
    required this.equipment,
  });

  /// All available body parts (from the dataset).
  final List<String> bodyParts;

  /// All available equipment types (from the dataset).
  final List<String> equipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(exerciseLibraryProvider.notifier);
    final filter = ref.watch(exerciseLibraryProvider).filter;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Body parts section
        const _SectionLabel(label: 'Body Part'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: bodyParts.map((bp) {
            final selected = filter.bodyParts.contains(bp);
            return GlassChip(
              label: bp,
              selected: selected,
              onSelected: (_) => notifier.toggleBodyPart(bp),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Equipment section
        const _SectionLabel(label: 'Equipment'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: equipment.map((eq) {
            final selected = filter.equipment.contains(eq);
            return GlassChip(
              label: eq,
              selected: selected,
              onSelected: (_) => notifier.toggleEquipment(eq),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Clear all button
        if (!filter.isEmpty)
          GlassButton(
            label: 'Clear All Filters',
            onPressed: notifier.clearFilters,
            style: GlassButtonStyle.text,
            expanded: true,
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
