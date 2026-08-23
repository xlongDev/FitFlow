import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/database_providers.dart';
import '../providers/default_plans_provider.dart';
import '../routers/route_names.dart';
import '../theme/theme.dart';
import '../utils/app_logger.dart';

/// Splash / bootstrap page.
///
/// Shown on cold start while the app performs one-time initialization:
///   * Opens the drift database.
///   * Imports the bundled `exercises.json` on first launch (idempotent —
///     subsequent launches skip the import).
///
/// Once bootstrap completes, navigates to the home page.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Defer bootstrap until after the first frame so the splash is visible
    // for at least one paint cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  /// Runs the one-time / per-launch bootstrap work.
  Future<void> _bootstrap() async {
    try {
      final repo = ref.read(exerciseRepositoryProvider);
      // importIfEmpty returns null on subsequent launches (table already
      // populated). On first launch it parses + inserts ~1300 exercises.
      final result = await repo.importIfEmpty();
      if (result != null) {
        AppLogger.i('Splash: first-launch exercise import complete — '
            '${result.success} exercises, ${result.failed} failed, '
            '${result.duplicated} duplicated');
      } else {
        AppLogger.d('Splash: exercises already imported, skipping');
      }

      // Import default training + diet plans on first launch.
      final plansResult = await ref.read(defaultPlansImportProvider.future);
      if (plansResult != null) {
        AppLogger.i('Splash: first-launch default plans imported — '
            '${plansResult.trainingPlansCreated} training plans, '
            '${plansResult.dietPlansCreated} diet plans');
      }
    } catch (e, st) {
      // Bootstrap failure should not block the app — log and continue so the
      // user can still use features that don't depend on the exercise library.
      AppLogger.e('Splash: bootstrap failed', e, st);
    }

    if (mounted) {
      context.go(RouteNames.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo placeholder — replaced with a real asset in a later phase.
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.xl2All,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  boxShadow: AppShadows.primaryGlow,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Fitness',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xl2),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
