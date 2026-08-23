import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// A Cupertino-style search bar with a frosted-glass background.
///
/// Used at the top of the exercise library. The text field is debounced by
/// the caller (the provider) — this widget just emits every change via
/// [onChanged] and lets the provider decide when to query.
class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search exercises',
    this.controller,
  });

  /// Called on every keystroke.
  final ValueChanged<String> onChanged;

  /// Called when the user submits the search (presses Enter).
  final ValueChanged<String>? onSubmitted;

  /// Placeholder text.
  final String hintText;

  /// Optional text controller (e.g. for clearing the field externally).
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x1AFFFFFF) // 10% white
            : const Color(0x0D000000), // 5% black
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        style: theme.textTheme.bodyLarge,
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            size: 20,
            color: theme.colorScheme.outline,
          ),
          suffixIcon: controller != null
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller!,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(
                        CupertinoIcons.clear_circled_solid,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      onPressed: () {
                        controller!.clear();
                        onChanged('');
                      },
                    );
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
