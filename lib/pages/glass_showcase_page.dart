import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme.dart';
import '../widgets/glass/glass.dart';

/// A gallery page that showcases every Liquid Glass component.
///
/// This page exists for two reasons:
///   1. **Visual QA** — designers / devs can see all Glass components in one
///      place, in both light and dark mode, to verify the design system.
///   2. **Living documentation** — each section's code is a copy-pasteable
///      example of how to use the component.
///
/// Reachable from the Home page's "Glass Showcase" entry. Not part of the
/// end-user product flow.
class GlassShowcasePage extends ConsumerStatefulWidget {
  const GlassShowcasePage({super.key});

  @override
  ConsumerState<GlassShowcasePage> createState() => _GlassShowcasePageState();
}

class _GlassShowcasePageState extends ConsumerState<GlassShowcasePage> {
  int _selectedSegment = 0;
  final Set<String> _selectedChips = {'Chest'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassNavigationBar(
        title: Text('Glass Showcase'),
      ),
      body: Stack(
        children: [
          // A colorful gradient background so the glass blur is visible.
          // In real screens this layer is the page content scrolling behind
          // the glass; here we use a static gradient for demonstration.
          const _GradientBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.xl4,
              ),
              children: [
                const _SectionTitle(title: 'GlassContainer'),
                const _GlassContainerDemo(),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassCard'),
                const _GlassCardDemo(),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassButton'),
                const _GlassButtonDemo(),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassChip'),
                _GlassChipDemo(
                  selected: _selectedChips,
                  onToggle: (label) {
                    setState(() {
                      if (_selectedChips.contains(label)) {
                        _selectedChips.remove(label);
                      } else {
                        _selectedChips.add(label);
                      }
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassSegmentedControl'),
                _GlassSegmentedDemo(
                  selected: _selectedSegment,
                  onChanged: (v) => setState(() => _selectedSegment = v),
                ),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassBottomSheet'),
                const _GlassBottomSheetDemo(),
                const SizedBox(height: AppSpacing.xl),

                const _SectionTitle(title: 'GlassDialog'),
                const _GlassDialogDemo(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gradient background — makes the glass blur visible
// ---------------------------------------------------------------------------

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFE0F7FA),
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFCE4EC),
                  ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GlassContainer demo
// ---------------------------------------------------------------------------

class _GlassContainerDemo extends StatelessWidget {
  const _GlassContainerDemo();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plain glass surface', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  'BackdropFilter + tint + border + shadow. Non-interactive.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GlassCard demo
// ---------------------------------------------------------------------------

class _GlassCardDemo extends StatelessWidget {
  const _GlassCardDemo();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              gradient: const LinearGradient(
                colors: [AppColors.tertiary, AppColors.primary],
              ),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tappable glass card', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  'Tap to see the 1.0 → 0.97 → 1.0 scale animation.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiaryLight),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GlassButton demo
// ---------------------------------------------------------------------------

class _GlassButtonDemo extends StatelessWidget {
  const _GlassButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        GlassButton(
          label: 'Primary',
          onPressed: () {},
        ),
        GlassButton(
          label: 'Secondary',
          onPressed: () {},
          style: GlassButtonStyle.secondary,
        ),
        GlassButton(
          label: 'Text',
          onPressed: () {},
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Destructive',
          onPressed: () {},
          style: GlassButtonStyle.destructive,
        ),
        const GlassButton(
          label: 'Disabled',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GlassChip demo
// ---------------------------------------------------------------------------

class _GlassChipDemo extends StatelessWidget {
  const _GlassChipDemo({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const _muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _muscleGroups.map((label) {
        return GlassChip(
          label: label,
          selected: selected.contains(label),
          onSelected: (_) => onToggle(label),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// GlassSegmentedControl demo
// ---------------------------------------------------------------------------

class _GlassSegmentedDemo extends StatelessWidget {
  const _GlassSegmentedDemo({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl<int>(
      value: selected,
      onChanged: onChanged,
      segments: const [
        GlassSegment(label: 'Grid', value: 0, icon: Icons.grid_view),
        GlassSegment(label: 'List', value: 1, icon: Icons.view_list),
        GlassSegment(label: 'Card', value: 2, icon: Icons.view_module),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GlassBottomSheet demo
// ---------------------------------------------------------------------------

class _GlassBottomSheetDemo extends StatelessWidget {
  const _GlassBottomSheetDemo();

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: 'Show Bottom Sheet',
      onPressed: () {
        unawaited(
          GlassBottomSheet.show(
            context,
            options: const GlassBottomSheetOptions(
              title: 'Filter Exercises',
              initialSize: 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Muscle Groups', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                const Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    GlassChip(label: 'Chest', selected: true),
                    GlassChip(label: 'Back'),
                    GlassChip(label: 'Legs', selected: true),
                    GlassChip(label: 'Shoulders'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassButton(
                  label: 'Apply Filters',
                  onPressed: () => Navigator.of(context).pop(),
                  expanded: true,
                ),
              ],
            ),
          ),
        );
      },
      style: GlassButtonStyle.secondary,
      expanded: true,
    );
  }
}

// ---------------------------------------------------------------------------
// GlassDialog demo
// ---------------------------------------------------------------------------

class _GlassDialogDemo extends StatelessWidget {
  const _GlassDialogDemo();

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: 'Show Dialog',
      onPressed: () {
        unawaited(
          GlassDialog.show<bool>(
            context,
            options: const GlassDialogOptions(title: 'Remove Exercise?'),
            child: Text(
              'This will remove the exercise from your plan. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              GlassButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(false),
                style: GlassButtonStyle.text,
              ),
              GlassButton(
                label: 'Remove',
                onPressed: () => Navigator.of(context).pop(true),
                style: GlassButtonStyle.destructive,
              ),
            ],
          ),
        );
      },
      style: GlassButtonStyle.secondary,
      expanded: true,
    );
  }
}
