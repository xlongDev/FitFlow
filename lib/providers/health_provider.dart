import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_data_model.dart';
import '../repositories/health_repository.dart';
import '../services/health_service.dart';
import '../services/mock_health_service.dart';
import '../utils/app_logger.dart';

/// State for the health dashboard.
sealed class HealthState {
  const HealthState();
}

class HealthInitial extends HealthState {
  const HealthInitial();
}

class HealthCheckingAvailability extends HealthState {
  const HealthCheckingAvailability();
}

class HealthUnauthorized extends HealthState {
  const HealthUnauthorized({required this.isAvailable});

  final bool isAvailable;
}

class HealthLoading extends HealthState {
  const HealthLoading();
}

class HealthData extends HealthState {
  const HealthData({
    required this.summary,
    required this.isAuthorized,
  });

  final DailyHealthSummary summary;
  final bool isAuthorized;
}

class HealthError extends HealthState {
  const HealthError(this.message);

  final String message;
}

/// Notifier that manages the health dashboard state.
///
/// On first load, checks availability and authorization. If unauthorized,
/// shows a "connect to Apple Health" prompt. If authorized, loads today's
/// summary.
class HealthNotifier extends Notifier<HealthState> {
  late HealthRepository _repo;

  @override
  HealthState build() {
    _repo = ref.watch(healthRepositoryProvider);
    unawaited(_checkAvailability());
    return const HealthInitial();
  }

  Future<void> _checkAvailability() async {
    state = const HealthCheckingAvailability();

    try {
      final isAvailable = await _repo.isAvailable;
      if (!ref.mounted) return;

      if (!isAvailable) {
        state = const HealthUnauthorized(isAvailable: false);
        return;
      }

      // Check if already authorized.
      final status = await _repo.authorizationStatusFor(
        HealthMetricType.stepCount,
      );
      if (!ref.mounted) return;

      if (status != HealthAuthorizationStatus.authorized) {
        state = const HealthUnauthorized(isAvailable: true);
        return;
      }

      // Already authorized — load data.
      await _loadData();
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Health: availability check failed', e, st);
      state = HealthError(e.toString());
    }
  }

  /// Requests authorization and loads data if granted.
  Future<void> requestAccess() async {
    state = const HealthLoading();

    try {
      final granted = await _repo.requestAuthorization();
      if (!ref.mounted) return;

      if (granted) {
        await _loadData();
      } else {
        state = const HealthUnauthorized(isAvailable: true);
      }
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Health: requestAccess failed', e, st);
      state = HealthError(e.toString());
    }
  }

  /// Reloads today's summary from Apple Health.
  Future<void> refresh() => _loadData();

  Future<void> _loadData() async {
    state = const HealthLoading();

    try {
      final summary = await _repo.todaySummary();
      if (!ref.mounted) return;
      state = HealthData(summary: summary, isAuthorized: true);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Health: load failed', e, st);
      state = HealthError(e.toString());
    }
  }
}

/// Provider that exposes the [HealthNotifier].
final healthProvider =
    NotifierProvider<HealthNotifier, HealthState>(HealthNotifier.new);

/// Provides the [HealthService] implementation.
///
/// On iOS, this would return [IosHealthService]. On all other platforms
/// (and in tests), it returns [MockHealthService] so the UI can be
/// developed without a physical device.
///
/// **Note:** [IosHealthService] is not yet wired up because the native
/// Swift HealthKit bridge hasn't been implemented. Until then, the mock
/// is used everywhere.
final healthServiceProvider = Provider<HealthService>((ref) {
  // When the iOS native bridge is ready, uncomment this:
  // if (defaultTargetPlatform == TargetPlatform.iOS) {
  //   return IosHealthService();
  // }
  if (kDebugMode) {
    AppLogger.d('HealthService: using MockHealthService '
        '(platform: $defaultTargetPlatform)');
  }
  return MockHealthService();
});

/// Provides the [HealthRepository], backed by [healthServiceProvider].
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final service = ref.watch(healthServiceProvider);
  return HealthRepository(service);
});
