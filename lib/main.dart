import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'routers/app_router.dart';
import 'theme/theme.dart';
import 'utils/app_logger.dart';

/// Entry point.
///
/// Phase 18: Production hardening — wraps the app in [runZonedGuarded] to
/// catch uncaught async errors, overrides [ErrorWidget] to prevent red
/// screens of death in release, and registers FlutterError.onError for
/// synchronous widget errors.
Future<void> main() async {
  // Run the app in a guarded zone so uncaught async errors are logged
  // instead of crashing the app silently.
  await runZonedGuarded<Future<void>>(() async {
    // Required before any async call when using plugins / MethodChannels.
    WidgetsFlutterBinding.ensureInitialized();

    // Override ErrorWidget so release builds show a blank widget instead
    // of the red error screen when a widget build throws.
    ErrorWidget.builder = (details) {
      AppLogger.e('Widget build error', details.exception, details.stack);
      return const SizedBox.shrink();
    };

    // Catch synchronous Flutter framework errors (widget build, layout, etc).
    FlutterError.onError = (details) {
      AppLogger.e('FlutterError', details.exception, details.stack);
      FlutterError.presentError(details);
    };

    // Lock phones to portrait.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Transparent status bar so the Liquid Glass background shows through.
    SystemChrome.setSystemUIOverlayStyle(AppTypography.lightStatusBar);

    AppLogger.i('Fitness app starting (Phase 18 — Production)');

    runApp(const ProviderScope(child: FitnessApp()));
  }, (error, stack) {
    // Catch uncaught async errors that escape the Flutter framework.
    AppLogger.e('Uncaught async error', error, stack);
  });
}

/// Root widget.
///
/// Phase 12: Added localization support — delegates + supported locales +
/// locale from [LocaleNotifier] (user can switch language in settings).
///
/// Phase 18: Added [ErrorWidget] override + [runZonedGuarded] in main().
class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final localePref = ref.watch(localeProvider);
    final locale = localePref.toLocale();

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 15 logical points
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) {
            // Keep the status bar style in sync with the active theme.
            final brightness = Theme.of(context).brightness;
            SystemChrome.setSystemUIOverlayStyle(
              brightness == Brightness.dark
                  ? AppTypography.darkStatusBar
                  : AppTypography.lightStatusBar,
            );
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
