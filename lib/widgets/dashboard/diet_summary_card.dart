import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Diet summary card — shows today's calorie intake vs target.
class DietSummaryCard extends ConsumerWidget {
  const DietSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final l = AppLocalizations.of(context)!;

    if (state is! HomeDashboardDataState) {
      return const SizedBox.shrink();
    }

    final nutrition = state.data.todayNutrition;
    final calories = nutrition?.totalCalories ?? 0;

    return GlassCard(
      onTap: () => context.push(RouteNames.dietPath),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.tertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.navDiet, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  '${calories.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
