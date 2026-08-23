import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../utils/app_logger.dart';

/// Data-access layer for subscription and in-app purchase management.
///
/// Wraps [SubscriptionService] and provides higher-level methods for
/// checking entitlements, gating features, and managing purchases. The UI
/// layer goes through this repository via a Riverpod provider — never
/// touches [SubscriptionService] directly.
class SubscriptionRepository {
  SubscriptionRepository(this._service);

  final SubscriptionService _service;

  /// Whether the platform supports in-app purchases.
  Future<bool> get isAvailable => _service.isAvailable;

  /// Returns the current subscription state.
  Future<SubscriptionState> get currentState => _service.currentState;

  /// Returns all available purchasable products.
  Future<List<ProductInfo>> getProducts() => _service.getProducts();

  /// Initiates a purchase for [productId].
  ///
  /// Returns `true` if the purchase was successful.
  Future<bool> purchase(String productId) async {
    try {
      final success = await _service.purchase(productId);
      AppLogger.i('SubscriptionRepository: purchase $productId → $success');
      return success;
    } catch (e, st) {
      AppLogger.e('SubscriptionRepository: purchase failed', e, st);
      return false;
    }
  }

  /// Restores previous purchases.
  Future<SubscriptionState> restorePurchases() async {
    try {
      final state = await _service.restorePurchases();
      AppLogger.i('SubscriptionRepository: restored → '
          '${state.entitlement.name}');
      return state;
    } catch (e, st) {
      AppLogger.e('SubscriptionRepository: restore failed', e, st);
      return const SubscriptionState(
        entitlement: Entitlement.free,
        status: SubscriptionStatus.inactive,
      );
    }
  }

  /// Checks whether [feature] is available for the current entitlement.
  Future<bool> isFeatureAvailable(PremiumFeature feature) {
    return _service.isFeatureAvailable(feature);
  }

  /// Checks whether the current entitlement is at least [tier].
  Future<bool> hasTier(Entitlement tier) async {
    final state = await _service.currentState;
    return state.entitlement.index >= tier.index;
  }
}
