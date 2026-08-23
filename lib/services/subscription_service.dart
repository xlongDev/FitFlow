import '../models/subscription_model.dart';

/// Abstract interface for in-app purchase and subscription management.
///
/// On iOS, the real implementation would use StoreKit via a MethodChannel.
/// On Android, it would use Google Play Billing. When no payment platform
/// is available (tests, desktop, web), the [MockSubscriptionService] is
/// used — it simulates purchases without real money.
///
/// The UI / Repository layer depends on this abstract interface, never on
/// the concrete implementation. This keeps IAP code out of the business
/// logic and makes the subscription feature testable.
abstract interface class SubscriptionService {
  /// Whether the platform supports in-app purchases.
  Future<bool> get isAvailable;

  /// Returns the current subscription state.
  ///
  /// On first launch, this returns a free-tier state. After a purchase,
  /// it returns the purchased entitlement.
  Future<SubscriptionState> get currentState;

  /// Returns all available purchasable products.
  Future<List<ProductInfo>> getProducts();

  /// Initiates a purchase for [productId].
  ///
  /// Returns `true` if the purchase was successful. On iOS, this triggers
  /// the StoreKit purchase dialog. The user can cancel — in that case,
  /// returns `false`.
  Future<bool> purchase(String productId);

  /// Restores previous purchases from the user's account.
  ///
  /// Called when the user taps "Restore Purchases". Returns the restored
  /// subscription state, or the current state if nothing was restored.
  Future<SubscriptionState> restorePurchases();

  /// Checks whether [feature] is available for the current entitlement.
  Future<bool> isFeatureAvailable(PremiumFeature feature);
}
