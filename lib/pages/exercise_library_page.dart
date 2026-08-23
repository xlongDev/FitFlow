import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/exercise_model.dart';
import '../../providers/exercise_library_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/common/skeleton_shimmer.dart';
import '../../widgets/common/states.dart';
import '../../widgets/exercise/exercise_card.dart';
import '../../widgets/exercise/exercise_filter_sheet.dart';
import '../../widgets/exercise/exercise_search_bar.dart';
import '../../widgets/glass/glass.dart';

/// The exercise library page.
///
/// Shows a searchable, filterable, paginated grid / list of all exercises
/// from the local database. This is the primary entry point for browsing
/// exercises.
///
/// Features:
///   * Cupertino search bar (debounced in the provider).
///   * Body-part + equipment multi-select filters (bottom sheet).
///   * Grid / list view toggle.
///   * Skeleton loading state.
///   * Empty state (no results).
///   * Error state (database failure).
///   * GIF thumbnails with caching.
class ExerciseLibraryPage extends ConsumerStatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  ConsumerState<ExerciseLibraryPage> createState() =>
      _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends ConsumerState<ExerciseLibraryPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseLibraryProvider);
    final notifier = ref.read(exerciseLibraryProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Cupertino-style large title with search bar.
          SliverAppBar.large(
            title: const Text('Exercises'),
            pinned: false,
            stretch: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                ),
                child: ExerciseSearchBar(
                  controller: _searchController,
                  onChanged: notifier.setQuery,
                ),
              ),
            ),
          ),
          // Toolbar: view toggle + filter button.
          SliverToBoxAdapter(
            child: _Toolbar(
              filter: state.filter,
              onToggleView: () {
                final next = state.filter.viewMode == ExerciseViewMode.grid
                    ? ExerciseViewMode.list
                    : ExerciseViewMode.grid;
                notifier.setViewMode(next);
              },
              onOpenFilters: () => _openFilterSheet(context),
            ),
          ),
          // Results.
          state.exercises.when(
            loading: () => const SliverFillRemaining(
              child: _LoadingGrid(),
            ),
            error: (error, _) => SliverFillRemaining(
              child: ErrorState(
                message: error.toString(),
                onRetry: notifier.refresh,
              ),
            ),
            data: (exercises) {
              if (exercises.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'No exercises found',
                    subtitle: 'Try adjusting your search or filters.',
                  ),
                );
              }
              return state.filter.viewMode == ExerciseViewMode.grid
                  ? _ExerciseGrid(exercises: exercises)
                  : _ExerciseList(exercises: exercises);
            },
          ),
          // Copyright footer.
          const SliverToBoxAdapter(
            child: _CopyrightFooter(),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final bodyParts = await ref.read(bodyPartsProvider.future);
    final equipment = await ref.read(equipmentListProvider.future);

    if (!mounted) return;

    if (!context.mounted) return;
    await GlassBottomSheet.show<void>(
      context,
      options: const GlassBottomSheetOptions(
        title: 'Filters',
        initialSize: 0.7,
      ),
      child: ExerciseFilterSheet(
        bodyParts: bodyParts,
        equipment: equipment,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid + List
// ---------------------------------------------------------------------------

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid({required this.exercises});

  final List<ExerciseModel> exercises;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final exercise = exercises[index];
            return ExerciseCard(
              exercise: exercise,
              onTap: () => context.push(
                '${RouteNames.exerciseLibraryPath}/${exercise.id}',
              ),
            );
          },
          childCount: exercises.length,
        ),
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({required this.exercises});

  final List<ExerciseModel> exercises;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      sliver: SliverList.separated(
        itemCount: exercises.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ExerciseCard(
            exercise: exercise,
            layout: ExerciseCardLayout.list,
            onTap: () => context.push(
              '${RouteNames.exerciseLibraryPath}/${exercise.id}',
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const ExerciseCardSkeleton(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.filter,
    required this.onToggleView,
    required this.onOpenFilters,
  });

  final ExerciseFilter filter;
  final VoidCallback onToggleView;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final activeCount =
        filter.bodyParts.length + filter.equipment.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // View toggle
          GlassContainer(
            blur: AppBlur.xs,
            radius: AppRadius.pill,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs3,
            ),
            child: Row(
              children: [
                _ViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  selected: filter.viewMode == ExerciseViewMode.grid,
                  onTap: onToggleView,
                ),
                const SizedBox(width: AppSpacing.xs),
                _ViewToggleButton(
                  icon: Icons.view_list_rounded,
                  selected: filter.viewMode == ExerciseViewMode.list,
                  onTap: onToggleView,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Filter button
          GlassButton(
            label: activeCount > 0 ? 'Filter ($activeCount)' : 'Filter',
            icon: Icons.tune,
            style: GlassButtonStyle.secondary,
            onPressed: onOpenFilters,
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Copyright footer
// ---------------------------------------------------------------------------

class _CopyrightFooter extends StatelessWidget {
  const _CopyrightFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl2,
      ),
      child: Center(
        child: Text(
          '© Gym visual — gymvisual.com',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
