import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The subscription page — shows available tiers and lets the user
/// purchase / restore.
///
/// Displays the current entitlement, a list of purchasable products, and
/// a "Restore Purchases" button. Each product card shows the title, price,
/// description, and a purchase button.
class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.subscriptionTitle)),
      body: switch (state) {
        SubscriptionLoading() => const Center(child: CircularProgressIndicator()),
        SubscriptionError(:final message) => ErrorState(
            message: message,
            onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
          ),
        SubscriptionLoaded(:final state, :final products) => ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // Current tier
              _CurrentTierCard(state: state),
              const SizedBox(height: AppSpacing.lg),

              // Available products
              Text(l.subscriptionAvailable, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              for (final product in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ProductCard(
                    product: product,
                    isCurrent: state.productId == product.id,
                    onPurchase: () => ref
                        .read(subscriptionProvider.notifier)
                        .purchase(product.id),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              // Restore button
              GlassButton(
                label: l.subscriptionRestore,
                icon: Icons.restore,
                style: GlassButtonStyle.secondary,
                expanded: true,
                onPressed: () =>
                    ref.read(subscriptionProvider.notifier).restorePurchases(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Feature comparison
              _FeatureComparison(currentEntitlement: state.entitlement),
              const SizedBox(height: AppSpacing.xl2),

              // Copyright
              Center(
                child: Text(
                  l.gymVisualCopyright,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
      },
    );
  }
}

/// Shows the user's current subscription tier.
class _CurrentTierCard extends StatelessWidget {
  const _CurrentTierCard({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierName = switch (state.entitlement) {
      Entitlement.free => 'Free',
      Entitlement.pro => 'Pro',
      Entitlement.premium => 'Premium',
    };
    final tierColor = switch (state.entitlement) {
      Entitlement.free => theme.colorScheme.outline,
      Entitlement.pro => AppColors.primary,
      Entitlement.premium => AppColors.secondary,
    };

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tierColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.entitlement == Entitlement.free
                  ? Icons.person_outline
                  : Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tierName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
                if (state.expiryDate != null)
                  Text(
                    '${state.isActive ? "Expires" : "Expired"}: '
                    '${state.expiryDate!.year}-'
                    '${state.expiryDate!.month.toString().padLeft(2, '0')}-'
                    '${state.expiryDate!.day.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  )
                else
                  Text(
                    state.isActive ? 'Active' : 'Inactive',
                    style: theme.textTheme.bodySmall?.copyWith(
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

/// A purchasable product card.
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isCurrent,
    required this.onPurchase,
  });

  final ProductInfo product;
  final bool isCurrent;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                product.price,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (isCurrent)
            GlassButton(
              label: l.subscriptionCurrent,
              style: GlassButtonStyle.text,
              expanded: true,
            )
          else
            GlassButton(
              label: l.subscriptionPurchase,
              icon: Icons.shopping_cart_outlined,
              expanded: true,
              onPressed: onPurchase,
            ),
        ],
      ),
    );
  }
}

/// A feature comparison table.
class _FeatureComparison extends StatelessWidget {
  const _FeatureComparison({required this.currentEntitlement});

  final Entitlement currentEntitlement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final features = <(String, Entitlement)>[
      (l.subscriptionFeatureExerciseLibrary, Entitlement.free),
      (l.subscriptionFeatureTrainingPlans, Entitlement.free),
      (l.subscriptionFeatureAiTraining, Entitlement.pro),
      (l.subscriptionFeatureAiDiet, Entitlement.pro),
      (l.subscriptionFeatureAnalytics, Entitlement.pro),
      (l.subscriptionFeatureWatch, Entitlement.pro),
      (l.subscriptionFeatureCloudSync, Entitlement.premium),
      (l.subscriptionFeaturePriorityAi, Entitlement.premium),
    ];

    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.subscriptionFeatures, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          for (final (name, requiredTier) in features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    currentEntitlement.index >= requiredTier.index
                        ? Icons.check_circle
                        : Icons.lock_outline,
                    size: 18,
                    color: currentEntitlement.index >= requiredTier.index
                        ? AppColors.tertiary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: currentEntitlement.index >= requiredTier.index
                            ? null
                            : theme.colorScheme.outline,
                      ),
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
