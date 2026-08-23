import 'package:fitness_app/models/subscription_model.dart';
import 'package:fitness_app/providers/subscription_provider.dart';
import 'package:fitness_app/repositories/subscription_repository.dart';
import 'package:fitness_app/services/mock_subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSubscriptionService mockService;
  late SubscriptionRepository repo;
  late ProviderContainer container;

  setUp(() {
    mockService = MockSubscriptionService();
    repo = SubscriptionRepository(mockService);

    container = ProviderContainer(
      overrides: [
        subscriptionServiceProvider.overrideWithValue(mockService),
        subscriptionRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MockSubscriptionService', () {
    test('isAvailable returns true', () async {
      expect(await mockService.isAvailable, isTrue);
    });

    test('initial state is free tier', () async {
      final state = await mockService.currentState;
      expect(state.entitlement, Entitlement.free);
      expect(state.status, SubscriptionStatus.inactive);
    });

    test('getProducts returns products', () async {
      final products = await mockService.getProducts();
      expect(products, isNotEmpty);
      expect(products.length, greaterThanOrEqualTo(3));
    });

    test('purchase grants entitlement', () async {
      final success = await mockService.purchase('pro_monthly');
      expect(success, isTrue);

      final state = await mockService.currentState;
      expect(state.entitlement, Entitlement.pro);
      expect(state.status, SubscriptionStatus.active);
      expect(state.expiryDate, isNotNull);
    });

    test('purchase unknown product returns false', () async {
      final success = await mockService.purchase('unknown');
      expect(success, isFalse);
    });

    test('isFeatureAvailable respects tier', () async {
      // Free tier — AI training plan not available.
      expect(
        await mockService.isFeatureAvailable(PremiumFeature.aiTrainingPlan),
        isFalse,
      );

      // Purchase Pro.
      await mockService.purchase('pro_monthly');

      // Now AI training plan should be available.
      expect(
        await mockService.isFeatureAvailable(PremiumFeature.aiTrainingPlan),
        isTrue,
      );
    });

    test('restorePurchases returns current state', () async {
      await mockService.purchase('premium_monthly');
      final restored = await mockService.restorePurchases();
      expect(restored.entitlement, Entitlement.premium);
    });
  });

  group('SubscriptionRepository', () {
    test('isAvailable delegates to service', () async {
      expect(await repo.isAvailable, isTrue);
    });

    test('purchase returns true for valid product', () async {
      final success = await repo.purchase('pro_yearly');
      expect(success, isTrue);
    });

    test('hasTier checks entitlement', () async {
      expect(await repo.hasTier(Entitlement.pro), isFalse);

      await repo.purchase('pro_monthly');

      expect(await repo.hasTier(Entitlement.pro), isTrue);
      expect(await repo.hasTier(Entitlement.premium), isFalse);
    });

    test('isFeatureAvailable delegates to service', () async {
      expect(
        await repo.isFeatureAvailable(PremiumFeature.cloudSync),
        isFalse,
      );

      await repo.purchase('premium_monthly');

      expect(
        await repo.isFeatureAvailable(PremiumFeature.cloudSync),
        isTrue,
      );
    });
  });

  group('SubscriptionProvider', () {
    test('initial state is loading', () {
      final state = container.read(subscriptionProvider);
      expect(state, isA<SubscriptionLoading>());
    });

    test('transitions to loaded after init', () async {
      final subscriber = container.listen(subscriptionProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 500));

      final state = subscriber.read();
      expect(state, isA<SubscriptionLoaded>());

      final loaded = state as SubscriptionLoaded;
      expect(loaded.state.entitlement, Entitlement.free);
      expect(loaded.products, isNotEmpty);

      subscriber.close();
    });

    test('purchase updates state', () async {
      final subscriber = container.listen(subscriptionProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 500));

      await container.read(subscriptionProvider.notifier).purchase('pro_monthly');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final state = subscriber.read() as SubscriptionLoaded;
      expect(state.state.entitlement, Entitlement.pro);

      subscriber.close();
    });
  });

  group('Feature gating', () {
    test('currentEntitlementProvider returns free initially', () async {
      // Need to wait for the provider to resolve.
      for (var i = 0; i < 10; i++) {
        final asyncValue = container.read(currentEntitlementProvider);
        final value = asyncValue.value;
        if (value != null) {
          expect(value, Entitlement.free);
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      // If we get here, the provider didn't resolve in time.
      fail('currentEntitlementProvider did not resolve');
    });

    test('featureAvailableProvider returns false for free tier', () async {
      for (var i = 0; i < 10; i++) {
        final asyncValue = container.read(
          featureAvailableProvider(PremiumFeature.aiTrainingPlan),
        );
        final value = asyncValue.value;
        if (value != null) {
          expect(value, isFalse);
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      fail('featureAvailableProvider did not resolve');
    });
  });
}
