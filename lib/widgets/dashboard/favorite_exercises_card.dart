import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Favorite exercises card — horizontal scroll of favorited exercises.
class FavoriteExercisesCard extends ConsumerWidget {
  const FavoriteExercisesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final l = AppLocalizations.of(context)!;

    if (state is! HomeDashboardDataState) {
      return const SizedBox.shrink();
    }

    final exercises = state.data.favoriteExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.navFavorites, style: Theme.of(context).textTheme.titleMedium),
              GestureDetector(
                onTap: () => context.push(RouteNames.favoritesPath),
                child: Text(
                  l.dashboardSeeAll,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
            itemCount: exercises.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return GestureDetector(
                onTap: () => context.push('${RouteNames.exerciseLibraryPath}/${exercise.id}'),
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.favorite, color: AppColors.secondary, size: 20),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
