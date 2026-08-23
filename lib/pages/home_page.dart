import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/home_dashboard_provider.dart';
import '../routers/route_names.dart';
import '../theme/theme.dart';
import '../widgets/dashboard/body_data_summary_card.dart';
import '../widgets/dashboard/diet_summary_card.dart';
import '../widgets/dashboard/favorite_exercises_card.dart';
import '../widgets/dashboard/quick_stats_card.dart';
import '../widgets/dashboard/recent_exercises_card.dart';
import '../widgets/dashboard/today_workout_card.dart';
import '../widgets/glass/glass.dart';

/// Home dashboard.
///
/// Phase 17: the full dashboard integrating all modules:
///   * Today's workout (from calendar)
///   * Quick stats (workout count, volume, weight)
///   * Quick access entries (exercises, plans, calendar, diet, etc.)
///   * Recent exercises (horizontal scroll)
///   * Favorite exercises (horizontal scroll)
///   * Body data summary
///   * Diet summary
///   * AI plans entry
///   * Subscription entry (if free tier)
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger dashboard data load.
    ref.watch(homeDashboardProvider);

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Large title app bar.
          SliverAppBar.large(
            title: Text(l.appTitle),
            pinned: false,
            stretch: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l.settings,
                onPressed: () => context.push(RouteNames.settingsPath),
              ),
            ],
          ),

          // Dashboard content.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's workout.
                  const TodayWorkoutCard(),
                  const SizedBox(height: AppSpacing.md),

                  // Quick stats.
                  const QuickStatsCard(),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick access grid.
                  _QuickAccessGrid(),
                  const SizedBox(height: AppSpacing.lg),

                  // Body data + Diet summary side by side.
                  const Row(
                    children: [
                      Expanded(child: BodyDataSummaryCard()),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(child: DietSummaryCard()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // AI plans entry.
                  _AIPlansEntry(),
                  const SizedBox(height: AppSpacing.lg),

                  // Subscription entry.
                  _SubscriptionEntry(),
                  const SizedBox(height: AppSpacing.lg),

                  // Glass showcase (dev/QA).
                  GlassCard(
                    onTap: () => context.push(RouteNames.glassShowcasePath),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.tertiary, AppColors.primary],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l.glassShowcase,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textTertiaryLight),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),

          // Recent exercises (horizontal scroll).
          const SliverToBoxAdapter(child: RecentExercisesCard()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Favorite exercises (horizontal scroll).
          const SliverToBoxAdapter(child: FavoriteExercisesCard()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl2)),

          // Copyright footer.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl2),
              child: Center(
                child: Text(
                  l.gymVisualCopyright,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick access grid — 2 rows of entry cards.
class _QuickAccessGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.fitness_center,
            label: l.exerciseLibrary,
            color: AppColors.primary,
            onTap: () => context.push(RouteNames.exerciseLibraryPath),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.assignment,
            label: l.navTrainingPlans,
            color: AppColors.secondary,
            onTap: () => context.push(RouteNames.trainingPlansPath),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.calendar_month,
            label: l.navCalendar,
            color: AppColors.tertiary,
            onTap: () => context.push(RouteNames.trainingCalendarPath),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// AI plans entry card.
class _AIPlansEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassCard(
      onTap: () => context.push(RouteNames.aiTrainingPlanPath),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.dashboardAIPlans, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  l.dashboardAISubtitle,
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

/// Subscription entry card.
class _SubscriptionEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassCard(
      onTap: () => context.push(RouteNames.subscriptionPath),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.tertiary],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.dashboardSubscription, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  l.dashboardSubscriptionSubtitle,
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
