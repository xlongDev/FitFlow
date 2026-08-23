import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_model.dart';
import '../repositories/subscription_repository.dart';
import '../services/mock_subscription_service.dart';
import '../services/subscription_service.dart';
import '../utils/app_logger.dart';

/// State for the subscription page.
sealed class SubscriptionPageState {
  const SubscriptionPageState();
}

class SubscriptionLoading extends SubscriptionPageState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionPageState {
  const SubscriptionLoaded({
    required this.state,
    required this.products,
  });

  final SubscriptionState state;
  final List<ProductInfo> products;
}

class SubscriptionError extends SubscriptionPageState {
  const SubscriptionError(this.message);

  final String message;
}

/// Notifier that manages the subscription page state.
///
/// On first load, fetches the current subscription state and available
/// products. The user can purchase / restore from the UI, which triggers
/// a state refresh.
class SubscriptionNotifier extends Notifier<SubscriptionPageState> {
  late SubscriptionRepository _repo;

  @override
  SubscriptionPageState build() {
    _repo = ref.watch(subscriptionRepositoryProvider);
    unawaited(_load());
    return const SubscriptionLoading();
  }

  Future<void> _load() async {
    try {
      final state = await _repo.currentState;
      final products = await _repo.getProducts();
      if (!ref.mounted) return;
      this.state = SubscriptionLoaded(state: state, products: products);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Subscription: load failed', e, st);
      state = SubscriptionError(e.toString());
    }
  }

  /// Initiates a purchase for [productId].
  Future<void> purchase(String productId) async {
    final success = await _repo.purchase(productId);
    if (success) {
      await _load();
    }
  }

  /// Restores previous purchases.
  Future<void> restorePurchases() async {
    await _repo.restorePurchases();
    await _load();
  }

  /// Refreshes the state.
  Future<void> refresh() => _load();
}

/// Provides the [SubscriptionService] implementation.
///
/// Currently uses [MockSubscriptionService] because no IAP platform is
/// configured. When StoreKit / BillingClient is ready, uncomment the
/// real implementation.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  // When the iOS/Android native bridge is ready:
  // if (defaultTargetPlatform == TargetPlatform.iOS) {
  //   return IosSubscriptionService();
  // } else if (defaultTargetPlatform == TargetPlatform.android) {
  //   return AndroidSubscriptionService();
  // }
  return MockSubscriptionService();
});

/// Provides the [SubscriptionRepository], backed by
/// [subscriptionServiceProvider].
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) {
    final service = ref.watch(subscriptionServiceProvider);
    return SubscriptionRepository(service);
  },
);

/// Provider for the subscription page state.
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionPageState>(
  SubscriptionNotifier.new,
);

/// A convenience provider that returns the current entitlement.
///
/// Used by feature-gating checks throughout the app (e.g. AI plan generation
/// checks if the user has Pro tier).
final currentEntitlementProvider = FutureProvider<Entitlement>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final state = await repo.currentState;
  return state.entitlement;
});

/// A family provider that checks whether a specific feature is available.
///
/// Usage:
/// ```dart
/// final canUseAi = ref.watch(featureAvailableProvider(
///   PremiumFeature.aiTrainingPlan,
/// ));
/// ```
final featureAvailableProvider =
    FutureProvider.family<bool, PremiumFeature>((ref, feature) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.isFeatureAvailable(feature);
});
