import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/training_plan_model.dart';
import '../../providers/training_plan_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_logger.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The training plan list page.
///
/// Shows all user-created training plans. Supports creating, duplicating,
/// and deleting plans. Tapping a plan navigates to its detail page.
class TrainingPlanPage extends ConsumerWidget {
  const TrainingPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trainingPlanListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New plan',
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: switch (state) {
        TrainingPlanListLoading() => const Center(child: CircularProgressIndicator()),
        TrainingPlanListError(:final message) => ErrorState(
            message: message,
            onRetry: () => ref.read(trainingPlanListProvider.notifier).refresh(),
          ),
        TrainingPlanListData(:final plans) => plans.isEmpty
            ? const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No training plans yet',
                subtitle: 'Tap + to create your first plan.',
              )
            : ListView.builder(
                padding: AppSpacing.pagePadding,
                itemCount: plans.length,
                itemBuilder: (context, index) => _PlanCard(
                  plan: plans[index],
                ),
              ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final result = await GlassDialog.show<bool>(
      context,
      options: const GlassDialogOptions(title: 'New Training Plan'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Plan name (e.g. Push Pull Legs)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Create',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result == true && nameController.text.trim().isNotEmpty && context.mounted) {
      await ref.read(trainingPlanListProvider.notifier).createPlan(
            name: nameController.text.trim(),
          );
    }
  }
}

/// A single plan card in the list.
class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});

  final TrainingPlanModel plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () => context.push('/training-plans/${plan.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.assignment, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs3),
                      Text(
                        '${plan.daysPerWeek} days/week · ${plan.days.length} exercises',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _onMenuAction(context, ref, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text('Duplicate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                plan.description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'duplicate':
        await ref.read(trainingPlanListProvider.notifier).duplicatePlan(plan.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan duplicated'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      case 'delete':
        final confirmed = await GlassDialog.show<bool>(
          context,
          options: GlassDialogOptions(title: 'Delete "${plan.name}"?'),
          child: const Text(
            'This will permanently delete the plan and all its days and exercises.',
          ),
          actions: [
            GlassButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(false),
              style: GlassButtonStyle.text,
            ),
            GlassButton(
              label: 'Delete',
              onPressed: () => Navigator.of(context).pop(true),
              style: GlassButtonStyle.destructive,
            ),
          ],
        );
        if (confirmed == true) {
          await ref.read(trainingPlanListProvider.notifier).deletePlan(plan.id);
        }
      default:
        AppLogger.w('Unknown menu action: $action');
    }
  }
}
