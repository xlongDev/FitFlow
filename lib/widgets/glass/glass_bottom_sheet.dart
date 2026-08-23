import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// Configuration for a [GlassBottomSheet].
class GlassBottomSheetOptions {
  const GlassBottomSheetOptions({
    this.title,
    this.dismissible = true,
    this.enableDrag = true,
    this.initialSize = 0.6,
    this.maxSize = 0.9,
  });

  /// Optional title shown at the top of the sheet.
  final String? title;

  /// Whether the sheet can be dismissed by tapping the scrim.
  final bool dismissible;

  /// Whether the sheet can be dragged down to dismiss.
  final bool enableDrag;

  /// Initial height as a fraction of the screen height.
  final double initialSize;

  /// Maximum height as a fraction of the screen height.
  final double maxSize;
}

/// A Liquid Glass bottom sheet.
///
/// Renders a frosted-glass sheet that slides up from the bottom of the
/// screen. The sheet blurs the content behind it and has a drag handle for
/// dismissal. Use this for filters, action menus, and detail panels.
///
/// Show the sheet via [GlassBottomSheet.show] — do NOT call
/// [showModalBottomSheet] directly with a [GlassBottomSheet] child, because
/// the sheet needs a transparent backdrop to let the blur show through.
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.options = const GlassBottomSheetOptions(),
  });

  /// The sheet content.
  final Widget child;

  /// Configuration.
  final GlassBottomSheetOptions options;

  /// Shows the sheet as a modal bottom sheet.
  ///
  /// Returns the value passed to [Navigator.pop] when the sheet is dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    GlassBottomSheetOptions options = const GlassBottomSheetOptions(),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      enableDrag: options.enableDrag,
      isDismissible: options.dismissible,
      showDragHandle: false,
      builder: (context) => GlassBottomSheet(
        options: options,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>()!;
    final mediaQuery = MediaQuery.of(context);

    return GlassContainer(
      blur: AppBlur.lg,
      radius: AppRadius.xl3,
      tint: glass.tint,
      border: glass.border,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * options.maxSize,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.padding.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle.
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              if (options.title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options.title!,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      if (options.dismissible)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Close',
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: theme.dividerColor,
                ),
              ],
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
