import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_model.dart';
import '../repositories/recently_viewed_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// Loads a single exercise by id.
///
/// Returns `null` when the exercise is not found (bad id or deleted). The
/// UI treats `null` as a "not found" state.
///
/// On successful load, records the view in [RecentlyViewedRepository] so the
/// home screen's "recent" list updates. The view recording is fire-and-forget
/// — it must not block the UI.
final exerciseDetailProvider =
    FutureProvider.family<ExerciseModel?, String>((ref, id) async {
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  final recentlyViewedRepo = ref.watch(recentlyViewedRepositoryProvider);

  final exercise = await exerciseRepo.getById(id);

  if (exercise != null) {
    // Record the view in the background — don't block the UI on this.
    unawaited(recentlyViewedRepo.recordView(id).catchError((Object e) {
      AppLogger.w('Failed to record view for $id', e);
    }));
  }

  return exercise;
});
