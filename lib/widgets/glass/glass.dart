/// Barrel file for the Liquid Glass widget library.
///
/// Import this single file to access all Glass components:
///
/// ```dart
/// import 'package:fitness_app/widgets/glass/glass.dart';
///
/// GlassCard(child: ...)
/// GlassButton(label: 'Save', onPressed: ...)
/// GlassChip(label: 'Chest', selected: true)
/// GlassSegmentedControl<int>(...)
/// GlassNavigationBar(title: Text('Home'))
/// GlassBottomSheet.show(context, child: ...)
/// GlassDialog.show(context, child: ...)
/// GlassContainer(child: ...)
/// ```
library;

export 'glass_bottom_sheet.dart';
export 'glass_button.dart';
export 'glass_card.dart';
export 'glass_chip.dart';
export 'glass_container.dart';
export 'glass_dialog.dart';
export 'glass_navigation_bar.dart';
export 'glass_segmented_control.dart';
