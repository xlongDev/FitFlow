import 'package:fitness_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('primary accent is opaque and blue-toned', () {
      expect(AppColors.primary.a, 1.0);
      expect(AppColors.primary, const Color(0xFF0A84FF));
    });

    test('semantic colors are distinct', () {
      expect(AppColors.success, isNot(equals(AppColors.error)));
      expect(AppColors.warning, isNot(equals(AppColors.info)));
    });

    test('glass tints are translucent', () {
      // Translucent colors must have alpha < 1.0, otherwise BackdropFilter
      // would be pointless (the tint would fully obscure the blur).
      expect(AppColors.glassTintLight.a, lessThan(1.0));
      expect(AppColors.glassTintDark.a, lessThan(1.0));
      expect(AppColors.glassBorderLight.a, lessThan(1.0));
      expect(AppColors.glassBorderDark.a, lessThan(1.0));
    });
  });

  group('AppSpacing', () {
    test('follows a 4pt grid', () {
      for (final v in [
        AppSpacing.xs3,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl2,
        AppSpacing.xl3,
        AppSpacing.xl4,
      ]) {
        expect(v % 4, 0, reason: '$v should be a multiple of 4');
      }
    });

    test('pagePadding is symmetric with the documented insets', () {
      expect(
        AppSpacing.pagePadding,
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageVertical,
        ),
      );
    });
  });

  group('AppRadius', () {
    test('pill is effectively infinite', () {
      expect(AppRadius.pill, greaterThan(999));
    });

    test('pre-built BorderRadius objects match their scalar counterparts', () {
      expect(AppRadius.xlAll, BorderRadius.circular(AppRadius.xl));
      expect(AppRadius.pillAll, BorderRadius.circular(AppRadius.pill));
    });
  });

  group('AppBlur', () {
    test('values are positive and ordered', () {
      expect(AppBlur.xs, greaterThan(0));
      expect(AppBlur.xs, lessThan(AppBlur.sm));
      expect(AppBlur.sm, lessThan(AppBlur.md));
      expect(AppBlur.md, lessThan(AppBlur.lg));
      expect(AppBlur.lg, lessThan(AppBlur.xl));
      expect(AppBlur.xl, lessThan(AppBlur.xl2));
    });
  });

  group('AppAnimation', () {
    test('durations are ordered', () {
      expect(AppAnimation.durationXs, lessThan(AppAnimation.durationSm));
      expect(AppAnimation.durationSm, lessThan(AppAnimation.durationMd));
      expect(AppAnimation.durationMd, lessThan(AppAnimation.durationLg));
      expect(AppAnimation.durationLg, lessThan(AppAnimation.durationXl));
    });

    test('pressedScale is between 0 and 1', () {
      expect(AppAnimation.pressedScale, greaterThan(0));
      expect(AppAnimation.pressedScale, lessThan(1));
    });
  });

  group('AppTheme', () {
    test('light theme has light brightness', () {
      expect(AppTheme.light().brightness, Brightness.light);
    });

    test('dark theme has dark brightness', () {
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('both themes register a GlassTheme extension', () {
      expect(AppTheme.light().extension<GlassTheme>(), isNotNull);
      expect(AppTheme.dark().extension<GlassTheme>(), isNotNull);
    });

    test('light and dark GlassThemes differ', () {
      final lightGlass = AppTheme.light().extension<GlassTheme>()!;
      final darkGlass = AppTheme.dark().extension<GlassTheme>()!;
      expect(lightGlass.tint, isNot(equals(darkGlass.tint)));
      expect(lightGlass.border, isNot(equals(darkGlass.border)));
    });
  });

  group('GlassTheme lerp', () {
    test('lerp at 0 returns the start theme', () {
      final lerped = GlassTheme.light.lerp(GlassTheme.dark, 0);
      expect(lerped.tint, GlassTheme.light.tint);
    });

    test('lerp at 1 returns the end theme', () {
      final lerped = GlassTheme.light.lerp(GlassTheme.dark, 1);
      expect(lerped.tint, GlassTheme.dark.tint);
    });
  });
}
