import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/body_metric_model.dart';
import '../../providers/body_metric_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The body data page — record and view body measurements.
///
/// Shows the latest measurement at the top, followed by a history list.
/// The user can add a new measurement via a bottom sheet form.
class BodyDataPage extends ConsumerWidget {
  const BodyDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add measurement',
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: switch (state) {
        BodyDataLoading() => const Center(child: CircularProgressIndicator()),
        BodyDataError(:final message) => ErrorState(
            message: message,
            onRetry: () => ref.read(bodyDataProvider.notifier).refresh(),
          ),
        BodyDataData(:final records, :final latest) => records.isEmpty
            ? const EmptyState(
                icon: Icons.monitor_weight,
                title: 'No measurements yet',
                subtitle: 'Add your first body measurement to start tracking.',
              )
            : ListView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  bottom: AppSpacing.xl2,
                ),
                children: [
                  if (latest != null) _LatestCard(metric: latest),
                  const SizedBox(height: AppSpacing.lg),
                  Text('History', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...records.map((r) => _HistoryTile(
                        metric: r,
                        onDelete: () => ref.read(bodyDataProvider.notifier).remove(r.id),
                      )),
                ],
              ),
      },
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final result = await _showMeasurementForm(context);
    if (result != null) {
      await ref.read(bodyDataProvider.notifier).add(result);
    }
  }

  Future<BodyMetricModel?> _showMeasurementForm(BuildContext context) async {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final waistController = TextEditingController();
    final chestController = TextEditingController();
    final hipController = TextEditingController();

    return showDialog<BodyMetricModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Measurement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) *',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: bodyFatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Body Fat (%)',
                  prefixIcon: Icon(Icons.percent),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: waistController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Waist (cm)',
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: chestController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chest (cm)',
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: hipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hip (cm)',
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight == null) return;
              final now = DateTime.now();
              Navigator.of(context).pop(BodyMetricModel(
                id: 'body-${now.microsecondsSinceEpoch}',
                date: now.toIso8601String(),
                weight: weight,
                bodyFat: double.tryParse(bodyFatController.text),
                waist: double.tryParse(waistController.text),
                chest: double.tryParse(chestController.text),
                hip: double.tryParse(hipController.text),
                createdAt: now.toIso8601String(),
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.metric});

  final BodyMetricModel metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metric.weight.toStringAsFixed(1),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text('kg', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (metric.bodyFat != null)
                _MetricChip(label: 'Body Fat', value: '${metric.bodyFat!.toStringAsFixed(1)}%'),
              if (metric.waist != null)
                _MetricChip(label: 'Waist', value: '${metric.waist!.toStringAsFixed(0)} cm'),
              if (metric.chest != null)
                _MetricChip(label: 'Chest', value: '${metric.chest!.toStringAsFixed(0)} cm'),
              if (metric.hip != null)
                _MetricChip(label: 'Hip', value: '${metric.hip!.toStringAsFixed(0)} cm'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.metric, required this.onDelete});

  final BodyMetricModel metric;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.tryParse(metric.date);
    final dateText = date != null
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : 'Unknown date';

    return Dismissible(
      key: ValueKey(metric.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateText, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(
                    '${metric.weight.toStringAsFixed(1)} kg'
                    '${metric.bodyFat != null ? ' · ${metric.bodyFat!.toStringAsFixed(1)}%' : ''}'
                    '${metric.waist != null ? ' · W:${metric.waist!.toStringAsFixed(0)}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
