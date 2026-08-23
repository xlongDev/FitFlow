import 'package:fitness_app/theme/theme.dart';
import 'package:fitness_app/widgets/glass/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassContainer', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const GlassContainer(child: Text('hello')),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('uses GlassTheme from context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const GlassContainer(child: SizedBox.shrink()),
        ),
      );

      // Verify BackdropFilter is present (the core of the glass effect).
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('respects custom radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const GlassContainer(
            radius: 8,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect((clipRRect.borderRadius as BorderRadius).topLeft.x, 8);
    });
  });

  group('GlassCard', () {
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: GlassCard(
            onTap: () => tapped++,
            child: const Text('card'),
          ),
        ),
      );

      await tester.tap(find.text('card'));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const GlassCard(child: Text('static')),
        ),
      );

      expect(find.text('static'), findsOneWidget);
    });
  });

  group('GlassButton', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Center(
            child: GlassButton(
              label: 'Save',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Center(
            child: GlassButton(label: 'Disabled'),
          ),
        ),
      );

      // The button should render but not respond to taps.
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // No crash, no callback fired — test passes by reaching this point.
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('renders all four styles without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Column(
            children: [
              GlassButton(
                label: 'Primary',
                onPressed: () {},
              ),
              GlassButton(
                label: 'Secondary',
                onPressed: () {},
                style: GlassButtonStyle.secondary,
              ),
              GlassButton(
                label: 'Text',
                onPressed: () {},
                style: GlassButtonStyle.text,
              ),
              GlassButton(
                label: 'Destructive',
                onPressed: () {},
                style: GlassButtonStyle.destructive,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Destructive'), findsOneWidget);
    });
  });

  group('GlassChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Center(child: GlassChip(label: 'Chest')),
        ),
      );

      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('calls onSelected with new value when tapped', (tester) async {
      bool? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Center(
            child: GlassChip(
              label: 'Back',
              onSelected: (v) => selected = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(selected, true);
    });
  });

  group('GlassSegmentedControl', () {
    testWidgets('renders all segments and calls onChanged', (tester) async {
      int? value;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: GlassSegmentedControl<int>(
                  segments: const [
                    GlassSegment(label: 'Grid', value: 0),
                    GlassSegment(label: 'List', value: 1),
                  ],
                  value: value ?? 0,
                  onChanged: (v) => setState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('List'), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      expect(value, 1);
    });
  });

  group('GlassNavigationBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            appBar: GlassNavigationBar(title: Text('My Title')),
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('preferredSize height is 56', (tester) async {
      const bar = GlassNavigationBar();
      expect(bar.preferredSize.height, 56);
    });
  });
}
