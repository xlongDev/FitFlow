import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// Configuration for a [GlassDialog].
class GlassDialogOptions {
  const GlassDialogOptions({
    this.title,
    this.dismissible = true,
  });

  /// Optional dialog title.
  final String? title;

  /// Whether the dialog can be dismissed by tapping outside.
  final bool dismissible;
}

/// A Liquid Glass centered dialog.
///
/// Renders a frosted-glass dialog with a title, content, and optional action
/// buttons. Use this for confirmations, alerts, and short forms.
///
/// Show the dialog via [GlassDialog.show] — do NOT call [showDialog] directly
/// with a [GlassDialog] child, because the dialog needs a transparent
/// barrier to let the blur show through.
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.child,
    this.actions = const [],
    this.options = const GlassDialogOptions(),
  });

  /// The dialog content.
  final Widget child;

  /// Action buttons shown at the bottom of the dialog. Typically
  /// [GlassButton]s or [TextButton]s.
  final List<Widget> actions;

  /// Configuration.
  final GlassDialogOptions options;

  /// Shows the dialog as a centered modal.
  ///
  /// Returns the value passed to [Navigator.pop] when the dialog is dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    List<Widget> actions = const [],
    GlassDialogOptions options = const GlassDialogOptions(),
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: options.dismissible,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => GlassDialog(
        options: options,
        actions: actions,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>()!;
    final mediaQuery = MediaQuery.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
        child: GlassContainer(
          blur: AppBlur.lg,
          radius: AppRadius.xl2,
          tint: glass.tint,
          border: glass.border,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: mediaQuery.size.width - AppSpacing.xl2 * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (options.title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      options.title!,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: child,
                ),
                if (actions.isNotEmpty) ...[
                  Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: theme.dividerColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: actions.length <= 2
                          ? MainAxisAlignment.spaceEvenly
                          : MainAxisAlignment.center,
                      children: actions,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
