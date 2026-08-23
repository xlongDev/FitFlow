import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/diet_model.dart';
import '../../providers/database_providers.dart';
import '../../providers/diet_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The diet plan page — manage daily nutrition target plans.
///
/// Shows all plans with their targets. The user can create new plans,
/// activate a plan (deactivating others), edit, or delete.
class DietPlanPage extends ConsumerWidget {
  const DietPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlans = ref.watch(dietPlanListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New plan',
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: asyncPlans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(dietPlanListProvider),
        ),
        data: (plans) => plans.isEmpty
            ? const EmptyState(
                icon: Icons.restaurant_menu,
                title: 'No diet plans yet',
                subtitle: 'Create a plan to set your daily nutrition targets.',
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _PlanCard(
                    plan: plan,
                    onActivate: () => _activatePlan(context, ref, plan.id),
                    onEdit: () => _showEditDialog(context, ref, plan),
                    onDelete: () => _confirmDelete(context, ref, plan),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final result = await _showPlanDialog(context);
    if (result != null) {
      await ref.read(dietRepositoryProvider).createPlan(
            name: result.name,
            goal: result.goal,
            targetCalories: result.targetCalories,
            targetProtein: result.targetProtein,
            targetCarbs: result.targetCarbs,
            targetFat: result.targetFat,
          );
      ref.invalidate(dietPlanListProvider);
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    DietPlanModel plan,
  ) async {
    final result = await _showPlanDialog(context, existing: plan);
    if (result != null) {
      await ref.read(dietRepositoryProvider).updatePlan(result);
      ref.invalidate(dietPlanListProvider);
    }
  }

  Future<DietPlanModel?> _showPlanDialog(
    BuildContext context, {
    DietPlanModel? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final goalController = TextEditingController(text: existing?.goal ?? '');
    final caloriesController = TextEditingController(
      text: existing?.targetCalories.toStringAsFixed(0) ?? '2000',
    );
    final proteinController = TextEditingController(
      text: existing?.targetProtein.toStringAsFixed(0) ?? '150',
    );
    final carbsController = TextEditingController(
      text: existing?.targetCarbs.toStringAsFixed(0) ?? '250',
    );
    final fatController = TextEditingController(
      text: existing?.targetFat.toStringAsFixed(0) ?? '65',
    );

    return showDialog<DietPlanModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing != null ? 'Edit Plan' : 'New Diet Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Plan Name'),
                  autofocus: true,
                ),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Goal (e.g. 增肌)'),
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Target Calories (kcal)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: proteinController,
                  decoration: const InputDecoration(labelText: 'Target Protein (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(labelText: 'Target Carbs (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fatController,
                  decoration: const InputDecoration(labelText: 'Target Fat (g)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  (existing ?? DietPlanModel(
                    id: '',
                    name: '',
                    createdAt: DateTime.now().toIso8601String(),
                  )).copyWith(
                    name: nameController.text.trim(),
                    goal: goalController.text.trim(),
                    targetCalories: double.tryParse(caloriesController.text) ?? 2000,
                    targetProtein: double.tryParse(proteinController.text) ?? 150,
                    targetCarbs: double.tryParse(carbsController.text) ?? 250,
                    targetFat: double.tryParse(fatController.text) ?? 65,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _activatePlan(
    BuildContext context,
    WidgetRef ref,
    String planId,
  ) async {
    await ref.read(dietRepositoryProvider).setActivePlan(planId);
    ref.invalidate(dietPlanListProvider);
    ref.invalidate(dietProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan activated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DietPlanModel plan,
  ) async {
    final confirmed = await GlassDialog.show<bool>(
      context,
      options: GlassDialogOptions(title: 'Delete "${plan.name}"?'),
      child: const Text('This will permanently delete the diet plan.'),
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
      await ref.read(dietRepositoryProvider).deletePlan(plan.id);
      ref.invalidate(dietPlanListProvider);
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
  });

  final DietPlanModel plan;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (plan.isActive) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (plan.goal.isNotEmpty)
                        Text(
                          plan.goal,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Targets row
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _TargetChip(
                  label: 'Calories',
                  value: '${plan.targetCalories.toStringAsFixed(0)} kcal',
                  color: AppColors.warning,
                ),
                _TargetChip(
                  label: 'Protein',
                  value: '${plan.targetProtein.toStringAsFixed(0)}g',
                  color: AppColors.primary,
                ),
                _TargetChip(
                  label: 'Carbs',
                  value: '${plan.targetCarbs.toStringAsFixed(0)}g',
                  color: AppColors.tertiary,
                ),
                _TargetChip(
                  label: 'Fat',
                  value: '${plan.targetFat.toStringAsFixed(0)}g',
                  color: AppColors.secondary,
                ),
              ],
            ),
            if (!plan.isActive) ...[
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                label: 'Activate',
                icon: Icons.check_circle_outline,
                style: GlassButtonStyle.secondary,
                expanded: true,
                onPressed: onActivate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
