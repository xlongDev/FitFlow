/// The user's subscription tier.
///
/// Each tier unlocks different features. The free tier is the default;
/// Pro and Premium require an in-app purchase.
enum Entitlement {
  /// Free tier — basic exercise library, basic training plans.
  free,

  /// Pro tier — AI training plans, AI diet plans, advanced analytics,
  /// advanced plans, Apple Watch advanced features.
  pro,

  /// Premium tier — everything in Pro, plus priority AI, unlimited
  /// custom plans, cloud sync, and early access to new features.
  premium,
}

/// Features that can be gated behind a subscription tier.
///
/// Used by [SubscriptionRepository.isFeatureAvailable] to check whether the
/// current entitlement allows a specific feature.
enum PremiumFeature {
  /// AI training plan generation.
  aiTrainingPlan,

  /// AI diet plan generation.
  aiDietPlan,

  /// Advanced body data analytics (trends, predictions).
  advancedAnalytics,

  /// Unlimited custom training plans (free tier is capped at 3).
  unlimitedCustomPlans,

  /// Apple Watch advanced features (live heart rate, workout sync).
  watchAdvanced,

  /// Cloud sync across devices.
  cloudSync,

  /// Priority AI processing (faster generation).
  priorityAi,
}

/// The status of a subscription.
enum SubscriptionStatus {
  /// No active subscription (free tier).
  inactive,

  /// Subscription is active and valid.
  active,

  /// Subscription has expired but is in the grace period.
  gracePeriod,

  /// Subscription was cancelled but still valid until expiry.
  cancelled,
}

/// Information about a purchasable product.
class ProductInfo {
  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.entitlement,
    required this.durationDays,
  });

  /// The product identifier (maps to StoreKit / BillingClient product id).
  final String id;

  /// Display title (e.g. "Pro Monthly").
  final String title;

  /// Display description.
  final String description;

  /// Display price (e.g. "$9.99").
  final String price;

  /// The entitlement this product grants.
  final Entitlement entitlement;

  /// Duration in days (30 for monthly, 365 for yearly, -1 for lifetime).
  final int durationDays;
}

/// The user's current subscription state.
class SubscriptionState {
  const SubscriptionState({
    required this.entitlement,
    required this.status,
    this.expiryDate,
    this.productId,
  });

  final Entitlement entitlement;
  final SubscriptionStatus status;

  /// When the subscription expires (null for free / lifetime).
  final DateTime? expiryDate;

  /// The product id that granted the current entitlement.
  final String? productId;

  /// Whether the user has at least the [tier] entitlement.
  bool hasTier(Entitlement tier) {
    return entitlement.index >= tier.index;
  }

  /// Whether the subscription is active (not expired).
  bool get isActive => status == SubscriptionStatus.active ||
      status == SubscriptionStatus.cancelled;
}
