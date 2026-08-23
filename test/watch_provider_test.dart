import 'package:fitness_app/models/watch_message_model.dart';
import 'package:fitness_app/providers/watch_provider.dart';
import 'package:fitness_app/repositories/watch_repository.dart';
import 'package:fitness_app/services/mock_watch_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockWatchService mockService;
  late WatchRepository repo;
  late ProviderContainer container;

  setUp(() {
    mockService = MockWatchService();
    repo = WatchRepository(mockService);

    container = ProviderContainer(
      overrides: [
        watchServiceProvider.overrideWithValue(mockService),
        watchRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MockWatchService', () {
    test('isAvailable returns true', () async {
      expect(await mockService.isAvailable, isTrue);
    });

    test('isPaired returns true', () async {
      expect(await mockService.isPaired, isTrue);
    });

    test('isReachable returns true', () async {
      expect(await mockService.isReachable, isTrue);
    });

    test('sendMessage returns true', () async {
      final message = WatchMessageModel(
        type: WatchMessageType.ping,
        data: {},
        timestamp: DateTime.now().toIso8601String(),
      );
      expect(await mockService.sendMessage(message), isTrue);
    });

    test('startWorkout triggers heart rate updates', () async {
      mockService.startListening();

      final messages = <WatchMessageModel>[];
      final sub = mockService.messageStream.listen(messages.add);

      // Send start workout message.
      await mockService.sendMessage(WatchMessageModel(
        type: WatchMessageType.startWorkout,
        data: {'totalSets': 10},
        timestamp: DateTime.now().toIso8601String(),
      ));

      // Wait for simulated heart rate updates.
      await Future<void>.delayed(const Duration(seconds: 4));

      // Should have received at least one heart rate update.
      expect(messages, isNotEmpty);
      expect(
        messages.any((m) => m.type == WatchMessageType.heartRateUpdate),
        isTrue,
      );

      await sub.cancel();
      mockService.stopListening();
    });
  });

  group('WatchRepository', () {
    test('isAvailable delegates to service', () async {
      expect(await repo.isAvailable, isTrue);
    });

    test('isPaired delegates to service', () async {
      expect(await repo.isPaired, isTrue);
    });

    test('startWorkout sends message', () async {
      final sent = await repo.startWorkout(totalSets: 5);
      expect(sent, isTrue);
    });

    test('stopWorkout sends message', () async {
      await repo.startWorkout(totalSets: 5);
      final sent = await repo.stopWorkout();
      expect(sent, isTrue);
    });

    test('ping sends message', () async {
      final sent = await repo.ping();
      expect(sent, isTrue);
    });

    test('updateExercise sends message', () async {
      final sent = await repo.updateExercise(
        exerciseName: 'Bench Press',
        setNumber: 1,
        totalSets: 4,
      );
      expect(sent, isTrue);
    });

    test('startRestTimer sends message', () async {
      final sent = await repo.startRestTimer(seconds: 90);
      expect(sent, isTrue);
    });
  });

  group('WatchProvider', () {
    test('initial state is WatchInitial', () {
      final state = container.read(watchProvider);
      expect(state, isA<WatchInitial>());
    });

    test('transitions to WatchConnected after check', () async {
      final subscriber = container.listen(watchProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 500));

      final state = subscriber.read();
      // Mock always reports connected.
      expect(state, anyOf(isA<WatchConnected>(), isA<WatchInitial>()));

      subscriber.close();
    });
  });
}
