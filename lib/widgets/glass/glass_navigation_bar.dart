import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// A frosted-glass top navigation bar.
///
/// Renders a translucent bar that blurs the content scrolling underneath it,
/// matching the iOS large-title navigation bar aesthetic. Supports a leading
/// action (usually back), a title, and optional trailing actions.
///
/// Use this inside a [SliverAppBar] or as the `appBar` of a [Scaffold]. For
/// scrollable pages, prefer wrapping the body in a [CustomScrollView] and
/// using [SliverGlassAppBar] (TODO Phase 3) so the bar blurs the scrolling
/// content.
class GlassNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassNavigationBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
  });

  /// The bar title. Pass a [Text] widget or a more complex title widget.
  final Widget? title;

  /// The leading widget. When `null` and [automaticallyImplyLeading] is
  /// `true`, a back button is shown if the route can pop.
  final Widget? leading;

  /// Trailing action widgets (usually [IconButton]s).
  final List<Widget> actions;

  /// Whether to automatically show a back button when the route can pop.
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modalRoute = ModalRoute.of(context);

    final effectiveLeading = leading ??
        (automaticallyImplyLeading && modalRoute?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
            : null);

    return GlassContainer(
      blur: AppBlur.sm,
      radius: 0,
      tint: theme.extension<GlassTheme>()!.tint,
      border: theme.extension<GlassTheme>()!.border,
      padding: EdgeInsets.zero,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: NavigationToolbar(
            leading: effectiveLeading,
            middle: title != null
                ? DefaultTextStyle(
                    style: theme.textTheme.titleLarge ?? const TextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: title!,
                  )
                : null,
            trailing: actions.isEmpty
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ),
      ),
    );
  }
}
