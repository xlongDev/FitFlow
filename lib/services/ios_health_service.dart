import 'package:flutter/services.dart';

import '../models/health_data_model.dart';
import '../utils/app_logger.dart';
import 'health_service.dart';

/// The MethodChannel-based HealthKit implementation.
///
/// This is the production implementation used on iOS. It communicates with
/// native Swift code via the `com.fitness_app/health` channel.
///
/// **Note:** The native iOS side (Swift HealthKit bridge) is not yet
/// implemented — it will be added when we have a macOS + Xcode build
/// environment. Until then, this class compiles but its methods will
/// throw [PlatformException] on iOS. The [MockHealthService] is used as
/// the default fallback.
class IosHealthService implements HealthService {
  IosHealthService();

  static const _channel = MethodChannel('com.fitness_app/health');

  @override
  Future<bool> get isAvailable async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosHealthService: isAvailable failed', e);
      return false;
    }
  }

  @override
  Future<HealthAuthorizationStatus> requestAuthorization(
    List<HealthMetricType> types,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'requestAuthorization',
        {'types': types.map((t) => t.name).toList()},
      );
      return _parseStatus(result);
    } catch (e) {
      AppLogger.w('IosHealthService: requestAuthorization failed', e);
      return HealthAuthorizationStatus.notDetermined;
    }
  }

  @override
  Future<HealthAuthorizationStatus> authorizationStatusFor(
    HealthMetricType type,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'authorizationStatus',
        {'type': type.name},
      );
      return _parseStatus(result);
    } catch (e) {
      AppLogger.w('IosHealthService: authorizationStatus failed', e);
      return HealthAuthorizationStatus.notDetermined;
    }
  }

  @override
  Future<List<HealthDataPointModel>> query(
    HealthMetricType type, {
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'query',
        {
          'type': type.name,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((m) => HealthDataPointModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      AppLogger.w('IosHealthService: query failed', e);
      return [];
    }
  }

  HealthAuthorizationStatus _parseStatus(String? status) {
    switch (status) {
      case 'authorized':
        return HealthAuthorizationStatus.authorized;
      case 'denied':
        return HealthAuthorizationStatus.denied;
      default:
        return HealthAuthorizationStatus.notDetermined;
    }
  }
}
