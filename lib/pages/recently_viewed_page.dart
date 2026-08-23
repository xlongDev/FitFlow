import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/exercise_model.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/common/skeleton_shimmer.dart';
import '../../widgets/common/states.dart';
import '../../widgets/exercise/exercise_card.dart';

/// The recently-viewed page.
///
/// Shows exercises the user has recently opened, newest-first. Tapping a
/// card navigates to the exercise detail page.
class RecentlyViewedPage extends ConsumerWidget {
  const RecentlyViewedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recentlyViewedListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        actions: [
          if (state is RecentlyViewedData && state.exercises.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () => _confirmClearHistory(context, ref),
            ),
        ],
      ),
      body: switch (state) {
        RecentlyViewedLoading() => const _LoadingList(),
        RecentlyViewedError(:final message) => ErrorState(
            message: message,
            onRetry: () =>
                ref.read(recentlyViewedListProvider.notifier).refresh(),
          ),
        RecentlyViewedData(:final exercises) => exercises.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                title: 'No history yet',
                subtitle: 'Exercises you view will appear here.',
              )
            : _HistoryList(exercises: exercises),
      },
    );
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This will remove all recently-viewed records. This action cannot be undone.',
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
      await ref.read(recentlyViewedListProvider.notifier).clearAll();
    }
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.exercises});

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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: ExerciseListRowSkeleton(),
      ),
    );
  }
}
