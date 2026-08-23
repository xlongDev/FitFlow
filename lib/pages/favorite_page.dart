import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/exercise_model.dart';
import '../../providers/favorite_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/common/skeleton_shimmer.dart';
import '../../widgets/common/states.dart';
import '../../widgets/exercise/exercise_card.dart';
import '../../widgets/exercise/exercise_search_bar.dart';

/// The favorites page.
///
/// Shows all exercises the user has favorited, with search and grid / list
/// view toggle. Tapping a card navigates to the exercise detail page.
class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoriteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (state is FavoriteListData && state.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.sm,
            ),
            child: ExerciseSearchBar(
              controller: _searchController,
              onChanged: (q) => setState(() => _query = q),
              hintText: 'Search favorites',
            ),
          ),
          // View toggle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Row(
              children: [
                _ViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  selected: _isGridView,
                  onTap: () => setState(() => _isGridView = true),
                ),
                const SizedBox(width: AppSpacing.xs),
                _ViewToggleButton(
                  icon: Icons.view_list_rounded,
                  selected: !_isGridView,
                  onTap: () => setState(() => _isGridView = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Content
          Expanded(
            child: switch (state) {
              FavoriteListLoading() => const _LoadingGrid(),
              FavoriteListError(:final message) => ErrorState(
                  message: message,
                  onRetry: () =>
                      ref.read(favoriteListProvider.notifier).refresh(),
                ),
              FavoriteListData(:final favorites) =>
                _filteredList(favorites),
            },
          ),
        ],
      ),
    );
  }

  Widget _filteredList(List<ExerciseModel> favorites) {
    final filtered = _query.isEmpty
        ? favorites
        : favorites
            .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: _query.isEmpty ? Icons.favorite_border : Icons.search_off,
        title: _query.isEmpty ? 'No favorites yet' : 'No matches',
        subtitle: _query.isEmpty
            ? 'Tap the heart icon on an exercise to save it here.'
            : 'Try a different search term.',
      );
    }

    if (_isGridView) {
      return _FavoriteGrid(exercises: filtered);
    }
    return _FavoriteList(exercises: filtered);
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
          'This will remove all exercises from your favorites. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(favoriteListProvider.notifier).clearAll();
    }
  }
}

class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid({required this.exercises});

  final List<ExerciseModel> exercises;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        bottom: AppSpacing.xl2,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(
          exercise: exercise,
          onTap: () => context.push(
            '${RouteNames.exerciseLibraryPath}/${exercise.id}',
          ),
        );
      },
    );
  }
}

class _FavoriteList extends StatelessWidget {
  const _FavoriteList({required this.exercises});

  final List<ExerciseModel> exercises;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        bottom: AppSpacing.xl2,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ExerciseCard(
            exercise: exercise,
            layout: ExerciseCardLayout.list,
            onTap: () => context.push(
              '${RouteNames.exerciseLibraryPath}/${exercise.id}',
            ),
          ),
        );
      },
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const ExerciseCardSkeleton(),
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
