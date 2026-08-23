import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('English locale loads correctly', (tester) async {
      late AppLocalizations l;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              l = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(l.appTitle, 'Fitness');
      expect(l.navHome, 'Home');
      expect(l.navExercises, 'Exercises');
      expect(l.settings, 'Settings');
      expect(l.language, 'Language');
      expect(l.english, 'English');
    });

    testWidgets('Chinese locale loads correctly', (tester) async {
      late AppLocalizations l;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: Builder(
            builder: (context) {
              l = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(l.appTitle, '健身');
      expect(l.navHome, '首页');
      expect(l.navExercises, '动作库');
      expect(l.settings, '设置');
      expect(l.language, '语言');
      expect(l.chinese, '简体中文');
    });

    testWidgets('supported locales include en and zh', (tester) async {
      final codes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet();
      expect(codes, contains('en'));
      expect(codes, contains('zh'));
    });
  });
}
