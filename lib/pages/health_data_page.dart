import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/health_data_model.dart';
import '../../providers/health_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The health data page — shows Apple Health metrics.
///
/// Displays today's steps, active energy, heart rate, distance, and flights
/// climbed. If the user hasn't authorized Apple Health, shows a "connect"
/// prompt instead.
class HealthDataPage extends ConsumerWidget {
  const HealthDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.healthData)),
      body: switch (state) {
        HealthInitial() || HealthCheckingAvailability() =>
          const Center(child: CircularProgressIndicator()),
        HealthUnauthorized(:final isAvailable) => _UnauthorizedState(
            isAvailable: isAvailable,
            onConnect: () =>
                ref.read(healthProvider.notifier).requestAccess(),
          ),
        HealthLoading() => const Center(child: CircularProgressIndicator()),
        HealthError(:final message) => ErrorState(
            message: message,
            onRetry: () => ref.read(healthProvider.notifier).refresh(),
          ),
        HealthData(:final summary) => _HealthSummary(summary: summary),
      },
    );
  }
}

class _UnauthorizedState extends StatelessWidget {
  const _UnauthorizedState({required this.isAvailable, required this.onConnect});

  final bool isAvailable;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.healthConnectTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.healthConnectSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassButton(
              label: l.healthConnect,
              icon: Icons.link,
              onPressed: onConnect,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.summary});

  final DailyHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Column(
            children: [
              Text(
                l.healthToday,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricGrid(summary: summary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.healthSources,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.healthSourcesSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});

  final DailyHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          icon: Icons.directions_walk,
          label: l.healthSteps,
          value: '${summary.steps}',
          unit: 'steps',
          color: AppColors.primary,
        ),
        _MetricCard(
          icon: Icons.local_fire_department,
          label: l.healthActiveEnergy,
          value: summary.activeEnergy.toStringAsFixed(0),
          unit: 'kcal',
          color: AppColors.secondary,
        ),
        _MetricCard(
          icon: Icons.favorite,
          label: l.healthHeartRate,
          value: '${summary.heartRate}',
          unit: 'bpm',
          color: AppColors.error,
        ),
        _MetricCard(
          icon: Icons.directions_run,
          label: l.healthDistance,
          value: (summary.distance / 1000).toStringAsFixed(2),
          unit: 'km',
          color: AppColors.tertiary,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
