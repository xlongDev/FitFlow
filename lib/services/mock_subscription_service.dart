import '../models/subscription_model.dart';
import '../utils/app_logger.dart';
import 'subscription_service.dart';

/// A [SubscriptionService] that simulates in-app purchases.
///
/// Used when:
///   * The platform doesn't support IAP (desktop, web).
///   * Running tests.
///   * No payment platform is configured.
///
/// The mock simulates the purchase flow: calling [purchase] with a valid
/// product id "succeeds" after a short delay and grants the corresponding
/// entitlement. No real money is charged.
class MockSubscriptionService implements SubscriptionService {
  MockSubscriptionService();

  /// The current subscription state. Starts as free tier.
  SubscriptionState _state = const SubscriptionState(
    entitlement: Entitlement.free,
    status: SubscriptionStatus.inactive,
  );

  /// All available products.
  static const _products = <ProductInfo>[
    ProductInfo(
      id: 'pro_monthly',
      title: 'Pro Monthly',
      description: 'AI plans, advanced analytics, Apple Watch features.',
      price: '\$9.99',
      entitlement: Entitlement.pro,
      durationDays: 30,
    ),
    ProductInfo(
      id: 'pro_yearly',
      title: 'Pro Yearly',
      description: 'Same as Pro Monthly, but 2 months free.',
      price: '\$79.99',
      entitlement: Entitlement.pro,
      durationDays: 365,
    ),
    ProductInfo(
      id: 'premium_monthly',
      title: 'Premium Monthly',
      description: 'Everything in Pro, plus cloud sync and priority AI.',
      price: '\$14.99',
      entitlement: Entitlement.premium,
      durationDays: 30,
    ),
    ProductInfo(
      id: 'premium_yearly',
      title: 'Premium Yearly',
      description: 'Same as Premium Monthly, but 2 months free.',
      price: '\$119.99',
      entitlement: Entitlement.premium,
      durationDays: 365,
    ),
    ProductInfo(
      id: 'premium_lifetime',
      title: 'Premium Lifetime',
      description: 'One-time purchase. All features, forever.',
      price: '\$299.99',
      entitlement: Entitlement.premium,
      durationDays: -1,
    ),
  ];

  /// Maps features to the minimum entitlement required.
  static const _featureTiers = <PremiumFeature, Entitlement>{
    PremiumFeature.aiTrainingPlan: Entitlement.pro,
    PremiumFeature.aiDietPlan: Entitlement.pro,
    PremiumFeature.advancedAnalytics: Entitlement.pro,
    PremiumFeature.unlimitedCustomPlans: Entitlement.pro,
    PremiumFeature.watchAdvanced: Entitlement.pro,
    PremiumFeature.cloudSync: Entitlement.premium,
    PremiumFeature.priorityAi: Entitlement.premium,
  };

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<SubscriptionState> get currentState async => _state;

  @override
  Future<List<ProductInfo>> getProducts() async {
    // Simulate network delay.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _products;
  }

  @override
  Future<bool> purchase(String productId) async {
    // Simulate purchase processing delay.
    await Future<void>.delayed(const Duration(seconds: 1));

    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      AppLogger.w('MockSubscriptionService: unknown product $productId');
      return false;
    }

    // Calculate expiry date.
    DateTime? expiry;
    if (product.durationDays > 0) {
      expiry = DateTime.now().add(Duration(days: product.durationDays));
    }

    _state = SubscriptionState(
      entitlement: product.entitlement,
      status: SubscriptionStatus.active,
      expiryDate: expiry,
      productId: productId,
    );

    AppLogger.i('MockSubscriptionService: purchased $productId → '
        '${product.entitlement.name} (expires: $expiry)');

    return true;
  }

  @override
  Future<SubscriptionState> restorePurchases() async {
    // Simulate restore delay.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // In the mock, there's nothing to restore — the state is in-memory.
    // In a real implementation, this would query StoreKit / BillingClient
    // for the user's previous purchases.
    AppLogger.i('MockSubscriptionService: restorePurchases → '
        'current state: ${_state.entitlement.name}');

    return _state;
  }

  @override
  Future<bool> isFeatureAvailable(PremiumFeature feature) async {
    final requiredTier = _featureTiers[feature]!;
    return _state.entitlement.index >= requiredTier.index;
  }
}
