import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Quick stats card — shows workout count, total volume, and latest weight.
class QuickStatsCard extends ConsumerWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final l = AppLocalizations.of(context)!;

    if (state is! HomeDashboardDataState) {
      return const SizedBox.shrink();
    }

    final data = state.data;
    final workoutCount = data.recentWorkouts.length;
    final totalVolume = data.recentWorkouts.fold(0.0, (sum, w) => sum + w.totalVolume);
    final latestWeight = data.latestBodyMetric?.weight;

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.dashboardQuickStats, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.fitness_center,
                  label: l.dashboardWorkouts,
                  value: '$workoutCount',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  icon: Icons.scale,
                  label: l.dashboardVolume,
                  value: '${totalVolume.toStringAsFixed(0)} kg',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  icon: Icons.monitor_weight,
                  label: l.dashboardWeight,
                  value: latestWeight != null
                      ? '${latestWeight.toStringAsFixed(1)} kg'
                      : '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs3),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
